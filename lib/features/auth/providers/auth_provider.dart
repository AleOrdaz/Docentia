import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/teacher_model.dart';

class AuthState {
  final Teacher? teacher;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.teacher,
    this.isAuthenticated = false, // ← antes era true
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Teacher? teacher,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      teacher: teacher ?? this.teacher,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _sub = _auth.authStateChanges().listen(_onUserChanged);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;
  int _applyGeneration = 0;
  String? _pendingProfileName;

  // Se dispara al abrir la app (sesión persistida), al loguear y al salir
  void _onUserChanged(User? user) {
    final generation = ++_applyGeneration;
    if (user == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }
    _publishTeacher(user, generation);
  }

  Future<void> _publishTeacher(
    User user,
    int generation, {
    Map<String, dynamic>? profile,
  }) async {
    var fresh = user;
    try {
      await user.reload();
      fresh = _auth.currentUser ?? user;
    } catch (_) {}
    if (generation != _applyGeneration) return;

    final saved = await StorageService.getTeacherName(fresh.uid);
    if (generation != _applyGeneration) return;

    String? tokenName;
    try {
      final claim = (await fresh.getIdTokenResult()).claims?['name'];
      if (claim is String) tokenName = claim;
    } catch (_) {}
    if (generation != _applyGeneration) return;

    final name = _pickHumanName(
      email: fresh.email,
      candidates: [
        _nameFromProfile(profile),
        _pendingProfileName,
        tokenName,
        fresh.displayName,
        ...fresh.providerData.map((info) => info.displayName),
        saved,
        state.teacher?.id == fresh.uid ? state.teacher?.name : null,
      ],
    );

    state = AuthState(
      isAuthenticated: true,
      teacher: _teacherFromUser(fresh, name: name, previous: state.teacher),
    );

    if (!_isHumanName(name, fresh.email)) return;

    await StorageService.saveTeacherName(fresh.uid, name);
    final currentDisplay = fresh.displayName?.trim() ?? '';
    if (currentDisplay != name && !_isHumanName(currentDisplay, fresh.email)) {
      try {
        await fresh.updateDisplayName(name);
      } catch (_) {}
    }
  }

  Teacher _teacherFromUser(User user, {required String name, Teacher? previous}) {
    final providerId =
        user.providerData.isNotEmpty ? user.providerData.first.providerId : '';
    return Teacher(
      id: user.uid,
      name: name,
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
      provider: providerId == 'apple.com' ? 'apple' : 'google',
      bio: previous?.bio,
      phone: previous?.phone ?? user.phoneNumber,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> signInWithGoogle() => _signIn(GoogleAuthProvider());

  Future<void> signInWithApple() => _signIn(
    AppleAuthProvider()..addScope('email')..addScope('name'),
  );

  Future<void> _signIn(AuthProvider provider) async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await _auth.signInWithProvider(provider);
      _pendingProfileName = _nameFromProfile(credential.additionalUserInfo?.profile);
      final user = credential.user ?? _auth.currentUser;
      if (user != null) {
        await _publishTeacher(
          user,
          ++_applyGeneration,
          profile: credential.additionalUserInfo?.profile,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'No se pudo iniciar sesión.');
    }
  }

  String _pickHumanName({
    required String? email,
    required List<String?> candidates,
  }) {
    final human = <String>[];
    for (final raw in candidates) {
      final value = raw?.trim() ?? '';
      if (_isHumanName(value, email)) human.add(value);
    }
    for (final value in human) {
      if (!_matchesEmailLocalPart(value, email)) return value;
    }
    return human.isNotEmpty ? human.first : 'Docente';
  }

  bool _isHumanName(String value, String? email) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains('@')) return false;
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    if (normalizedEmail.isNotEmpty && trimmed.toLowerCase() == normalizedEmail) {
      return false;
    }
    return true;
  }

  bool _matchesEmailLocalPart(String value, String? email) {
    final local = email?.split('@').first.trim().toLowerCase() ?? '';
    if (local.isEmpty) return false;
    String compact(String input) =>
        input.toLowerCase().replaceAll(RegExp(r'[\s._-]'), '');
    return compact(value) == compact(local);
  }

  String? _nameFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final name = profile['name'] ?? profile['fullName'];
    if (name is String) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty && !trimmed.contains('@')) return trimmed;
    }
    final given = profile['given_name'] ?? profile['givenName'];
    final family = profile['family_name'] ?? profile['familyName'];
    final parts = <String>[
      if (given is String && given.trim().isNotEmpty) given.trim(),
      if (family is String && family.trim().isNotEmpty) family.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  String? _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'canceled':
      case 'web-context-canceled':
        return null; // el usuario cerró la ventana, no mostrar error
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet.';
      default:
        return 'Error al iniciar sesión (${e.code}).';
    }
  }

  Future<void> signOut() => _auth.signOut();

  void updateProfile({String? name, String? phone, String? bio}) {
    final teacher = state.teacher;
    if (teacher == null) return;
    final updated = teacher.copyWith(name: name, phone: phone, bio: bio);
    state = state.copyWith(teacher: updated);
    final trimmed = name?.trim();
    if (trimmed != null && _isHumanName(trimmed, updated.email)) {
      StorageService.saveTeacherName(updated.id, trimmed);
      _auth.currentUser?.updateDisplayName(trimmed);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});