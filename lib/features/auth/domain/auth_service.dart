import '../../../core/network/api_client.dart';
import '../data/auth_api.dart';
import '../data/storage_service.dart';

class AuthService {
  AuthService({AuthApi? authApi}) : _authApi = authApi ?? AuthApi(ApiClient());

  final AuthApi _authApi;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _authApi.login(
      username: username,
      password: password,
    );
    final token = response['token']?.toString() ?? '';
    final userId = response['user_id']?.toString() ?? '';
    if (token.isNotEmpty && userId.isNotEmpty) {
      await StorageService.saveAuth(token: token, userId: userId);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _authApi.register(
      username: username,
      email: email,
      phone: phone,
      password: password,
    );
    final token = response['token']?.toString() ?? '';
    final userId = response['user_id']?.toString() ?? '';
    if (token.isNotEmpty && userId.isNotEmpty) {
      await StorageService.saveAuth(token: token, userId: userId);
    }
  }

  Future<void> verifyRegisterOtp({required String email, required String otp}) {
    return _authApi.verifyRegisterOtp(email: email, otp: otp);
  }

  Future<void> resendRegisterOtp(String email) {
    return _authApi.resendRegisterOtp(email);
  }

  Future<void> forgotPassword(String email) {
    return _authApi.forgotPassword(email);
  }

  Future<void> verifyForgotOtp({required String email, required String otp}) {
    return _authApi.verifyForgotOtp(email: email, otp: otp);
  }

  Future<void> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _authApi.resetForgotPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    final token = response['token']?.toString() ?? '';
    final userId = response['user_id']?.toString() ?? '';
    if (token.isNotEmpty && userId.isNotEmpty) {
      await StorageService.saveAuth(token: token, userId: userId);
    }
  }

  Future<bool> verifyExistingToken() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty || token == 'null') {
      return false;
    }
    try {
      final response = await _authApi.verifyToken(token);
      if (response['success'] == true) {
        final userId = response['user_id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          await StorageService.saveAuth(token: token, userId: userId);
        }
        return true;
      }
      return false;
    } on ApiException {
      return false;
    }
  }
}
