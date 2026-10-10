import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Se dispara al abrir la app (sesión persistida), al loguear y al salir
  void _onUserChanged(User? user) {
    if (user == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }
    state = AuthState(
      isAuthenticated: true,
      teacher: _teacherFromUser(user, previous: state.teacher),
    );
  }

  Teacher _teacherFromUser(User user, {Teacher? previous}) {
    final providerId =
    user.providerData.isNotEmpty ? user.providerData.first.providerId : '';
    final email = user.email ?? '';
    return Teacher(
      id: user.uid,
      name: user.displayName ??
          previous?.name ??
          (email.isNotEmpty ? email.split('@').first : 'Docente'),
      email: email,
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
      await _auth.signInWithProvider(provider);
      // _onUserChanged actualiza el estado solo
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'No se pudo iniciar sesión.');
    }
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
    if (state.teacher != null) {
      state = state.copyWith(
        teacher: state.teacher!.copyWith(name: name, phone: phone, bio: bio),
      );
      // TODO: guardar en Firestore (ver nota al final)
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