part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  final UserModel _user;

  const AuthState(this._user);

  @override
  List<Object> get props => [];

  UserModel? getUser(){
    return _user;
  }
}

class AutStateInit extends AuthState {
  const AutStateInit(UserModel user) : super(user);
}

class AuthStateAuthetificated extends AuthState {
  AuthStateAuthetificated(UserModel user) : super(user){
  }

  @override
  String toString() => 'UserSignedIn {User: $_user}';
}

class AuthStateNotAuthentificated extends AuthState {
  AuthStateNotAuthentificated() : super(UserModel.empty);

  @override
  String toString() => 'User not signed in';
}