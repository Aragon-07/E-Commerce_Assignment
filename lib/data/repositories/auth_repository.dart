import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_storage.dart';

class AuthSession {
  final String token;
  final UserModel? user;

  const AuthSession({required this.token, this.user});
}

/// Handles authentication, OTP verification, session persistence, and user profile CRUD.
class AuthRepository {
  AuthRepository({
    required this._apiClient,
    required this._authStorage,
  });

  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  Future<AuthSession?> loadSession() async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) return null;
    _apiClient.setToken(token);
    final user = await _authStorage.getUser();
    return AuthSession(token: token, user: user);
  }

  Future<ApiResponse<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiUrls.login,
      includeAuth: false,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    final session = _extractSession(response.data);
    if (session == null) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: 'Login succeeded but no token was returned.',
      );
    }

    _apiClient.setToken(session.token);
    await _authStorage.saveSession(token: session.token, user: session.user);

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: session,
    );
  }

  Future<ApiResponse<String>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? address,
  }) async {
    final body = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim(),
      'password': password,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
    };

    final response = await _apiClient.post(
      ApiUrls.signup,
      includeAuth: false,
      body: body,
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: email.trim(),
    );
  }

  Future<ApiResponse<AuthSession?>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiUrls.verifyOtp,
      includeAuth: false,
      body: {
        'email': email.trim(),
        'otp': otp.trim(),
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    final session = _extractSession(response.data);
    if (session != null) {
      _apiClient.setToken(session.token);
      await _authStorage.saveSession(token: session.token, user: session.user);
    }

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: session,
    );
  }

  Future<ApiResponse<void>> resendOtp({required String email}) async {
    final response = await _apiClient.post(
      ApiUrls.resendOtp,
      includeAuth: false,
      body: {'email': email.trim()},
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _apiClient.get(ApiUrls.profile);
    if (!response.isSuccess || response.data is! Map<String, dynamic>) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    final map = response.data as Map<String, dynamic>;
    final userMap = map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : map;
    final user = UserModel.fromJson(userMap);
    await _authStorage.saveUser(user);

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: user,
    );
  }

  Future<ApiResponse<UserModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? address,
  }) async {
    final body = <String, dynamic>{
      if (firstName != null && firstName.trim().isNotEmpty)
        'first_name': firstName.trim(),
      if (lastName != null && lastName.trim().isNotEmpty)
        'last_name': lastName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
    };

    final response = await _apiClient.patch(ApiUrls.profile, body: body);
    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      final userMap = map['user'] is Map<String, dynamic>
          ? map['user'] as Map<String, dynamic>
          : map;
      final user = UserModel.fromJson(userMap);
      await _authStorage.saveUser(user);
      return ApiResponse.success(
        statusCode: response.statusCode,
        message: response.message,
        data: user,
      );
    }

    return getProfile();
  }

  Future<void> logout() async {
    _apiClient.setToken(null);
    await _authStorage.clearSession();
  }

  AuthSession? _extractSession(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) return null;

    UserModel? user;
    if (data['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }
    return AuthSession(token: token, user: user);
  }
}
