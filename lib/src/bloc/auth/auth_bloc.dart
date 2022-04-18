import 'package:bloc/bloc.dart';
import 'package:roleplaying_app/src/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AutStateInit(UserModel(id: ''))){
    on<UserLoggedIn>(_onLoggedIn);
    on<UserLoggedOut>(_onLoggedOut);
    on<UserInit>(_onStarted);
  }

  void _onStarted(UserInit event, Emitter<AuthState> emit) {
    emit(const AutStateInit(UserModel.empty));
  }

  void _onLoggedIn(UserLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthStateAuthetificated(event.user));
  }

  void _onLoggedOut(UserLoggedOut event, Emitter<AuthState> emit) {
    emit(AuthStateNotAuthentificated());
  }
}