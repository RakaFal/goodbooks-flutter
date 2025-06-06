import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginWithEmailButtonPressed extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailButtonPressed({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInButtonPressed extends AuthEvent {}