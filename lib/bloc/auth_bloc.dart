import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider authProvider;

  AuthBloc({required this.authProvider}) : super(AuthInitial()) {
    on<LoginWithEmailButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        await authProvider.loginWithEmailAndPassword(event.email, event.password);
        emit(AuthSuccess("Login berhasil"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleSignInButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        await authProvider.signInWithGoogle();
        emit(AuthSuccess("Login berhasil"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}