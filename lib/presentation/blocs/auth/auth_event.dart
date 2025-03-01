part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = _Started;
  const factory AuthEvent.loggedIn({
    required BuildContext context,
    required String email,
    required String password,
  }) = _LoggedIn;
  const factory AuthEvent.registered({
    required BuildContext context,
    required String email,
    required String password,
  }) = _Registered;
  const factory AuthEvent.loggedOut() = _LoggedOut;
}
