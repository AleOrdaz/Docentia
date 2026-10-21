import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/teacher_model.dart';
import '../utils/teacher_name.dart';

class AuthState {
  final Teacher? teacher;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.teacher,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  bool get needsProfileSetup =>
      isAuthenticated && !isLoading && teacherNeedsProfileSetup(teacher);

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

  void _onUserChanged(User? user) {
    if (user == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }
    final alreadyIn = state.isAuthenticated && state.teacher?.id == user.uid;
    if (!alreadyIn) {
      state = state.copyWith(isLoading: true);
    }
    unawaited(_hydrateTeacher(user));
  }

  Future<void> _hydrateTeacher(User user) async {
    final saved = await StorageService.getTeacher(user.uid);
    if (_auth.currentUser?.uid != user.uid) return;

    state = AuthState(
      isAuthenticated: true,
      teacher: _teacherFromUser(
        user,
        previous: saved ?? state.teacher,
      ),
    );
  }

  Teacher _teacherFromUser(User user, {Teacher? previous}) {
    final email = user.email ?? '';
    String providerId = '';
    String? providerDisplayName;
    for (final info in user.providerData) {
      if (providerId.isEmpty) providerId = info.providerId;
      providerDisplayName ??= info.displayName;
    }

    return Teacher(
      id: user.uid,
      name: resolveTeacherName(
        displayName: user.displayName,
        providerDisplayName: providerDisplayName,
        previousName: previous?.name,
        email: email,
      ),
      email: email,
      photoUrl: (previous?.photoUrl.isNotEmpty == true)
          ? previous!.photoUrl
          : (user.photoURL ?? ''),
      provider: providerId == 'apple.com' ? 'apple' : 'google',
      bio: previous?.bio,
      phone: previous?.phone ?? user.phoneNumber,
      createdAt: previous?.createdAt ?? user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> signInWithGoogle() => _signIn(GoogleAuthProvider());

  Future<void> signInWithApple() => _signIn(
        AppleAuthProvider()
          ..addScope('email')
          ..addScope('name'),
      );

  Future<void> _signIn(AuthProvider provider) async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo iniciar sesión.',
      );
    }
  }

  String? _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'canceled':
      case 'web-context-canceled':
        return null;
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet.';
      default:
        return 'Error al iniciar sesión (${e.code}).';
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    final current = state.teacher;
    if (current == null) return;

    final updated = current.copyWith(
      name: name?.trim(),
      phone: phone?.trim(),
      bio: bio?.trim(),
      photoUrl: photoUrl,
    );
    state = state.copyWith(teacher: updated);
    await StorageService.saveTeacher(updated);

    final displayName = updated.name.trim();
    if (displayName.isNotEmpty && displayName != kFallbackTeacherName) {
      try {
        await _auth.currentUser?.updateDisplayName(displayName);
      } catch (_) {}
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
