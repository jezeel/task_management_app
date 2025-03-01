import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:task_mngmt/domain/repositories/auth_repository.dart';
import 'package:task_mngmt/domain/entities/user.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    // Create instance of Hive box for User
    var userBox = Hive.box<User>('users');

    on<AuthEvent>((event, emit) async {
      await event.map(
        started: (_) async {
          final user = await _authRepository.getCurrentUser();
          if (user != null) {
            emit(AuthState.authenticated(user));
          } else {
            emit(const AuthState.unauthenticated());
          }
        },
        loggedIn: (e) async {
          emit(const AuthState.loading());
          try {
            final user = await _authRepository.login(
              context: e.context,
              email: e.email,
              password: e.password,
            );
            userBox.put('user', user);
            emit(AuthState.authenticated(user));
          } catch (error) {
            emit(AuthState.error(error.toString()));
          }
        },
        registered: (e) async {
          emit(const AuthState.loading());
          try {
            final user = await _authRepository.register(
              context: e.context,
              email: e.email,
              password: e.password,
            );
            emit(AuthState.authenticated(user));
          } catch (error) {
            emit(AuthState.error(error.toString()));
          }
        },
        loggedOut: (_) async {
          await _authRepository.logout();
          emit(const AuthState.unauthenticated());
        },
      );
    });
  }
}
