import '../../../core/network/api_client.dart';
import '../data/auth_api.dart';
import '../data/storage_service.dart';

class AuthService {
  AuthService({AuthApi? authApi}) : _authApi = authApi ?? AuthApi(ApiClient());

  final AuthApi _authApi;

  Future<void> _persistAuthResponse(Map<String, dynamic> response) async {
    final token = response['token']?.toString() ?? '';
    final userId = response['user_id']?.toString() ?? '';
    if (token.isNotEmpty && userId.isNotEmpty) {
      await StorageService.saveAuth(token: token, userId: userId);
    }

    final user = response['user'];
    if (user is Map) {
      await StorageService.saveUserProfile(
        userName: user['user_name']?.toString(),
        fullName: user['full_name']?.toString(),
        email: user['email']?.toString(),
      );
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _authApi.login(
      username: username,
      password: password,
    );
    await _persistAuthResponse(response);
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
    await _persistAuthResponse(response);
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
    await _persistAuthResponse(response);
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
        final user = response['user'];
        if (user is Map) {
          await StorageService.saveUserProfile(
            userName: user['user_name']?.toString(),
            fullName: user['full_name']?.toString(),
            email: user['email']?.toString(),
          );
        }
        return true;
      }
      return false;
    } on ApiException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
