class AuthRepository {
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: validate against users table in Drift database
    if (password.length < 4) {
      throw Exception('Kata sandi salah.');
    }
  }
}
