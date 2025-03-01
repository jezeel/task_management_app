import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_mngmt/domain/repositories/user_repository.dart';
import 'package:task_mngmt/domain/entities/user.dart';
import 'package:injectable/injectable.dart';

part 'user_event.dart';
part 'user_state.dart';
part 'user_bloc.freezed.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(const UserState.initial()) {
    on<UserEvent>((event, emit) async {
      await event.map(
        started: (_) async {
          emit(const UserState.loading());
          try {
            final users = await _userRepository.getUsers(event.context);
            emit(UserState.loaded(users));
          } catch (error) {
            emit(UserState.error(error.toString()));
          }
        },
      );
    });
  }
}
