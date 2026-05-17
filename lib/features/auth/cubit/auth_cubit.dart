import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasir_rakyat/features/auth/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial());

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      emit(const AuthState.error('Nomor HP/email dan kata sandi wajib diisi.'));
      return;
    }
    emit(const AuthState.loading());
    try {
      await _repository.login(identifier: identifier, password: password);
      emit(const AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  void reset() => emit(const AuthState.initial());
}
