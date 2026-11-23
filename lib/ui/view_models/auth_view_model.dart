import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Manages authentication state, session persistence, OTP verification, and profile updates.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  String? _token;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initSession() async {
    final session = await _authRepository.loadSession();
    if (session != null) {
      _token = session.token;
      _user = session.user;
      notifyListeners();
      if (_user == null) {
        await fetchProfile();
      }
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _authRepository.login(email: email, password: password);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _token = res.data!.token;
      _user = res.data!.user;
      notifyListeners();
      if (_user == null) {
        await fetchProfile();
      }
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _authRepository.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      city: city,
      address: address,
    );
    _isLoading = false;

    if (res.isSuccess) {
      notifyListeners();
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _authRepository.verifyOtp(email: email, otp: otp);
    _isLoading = false;

    if (res.isSuccess) {
      if (res.data != null) {
        _token = res.data!.token;
        _user = res.data!.user;
      }
      notifyListeners();
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> resendOtp({required String email}) async {
    _errorMessage = null;
    final res = await _authRepository.resendOtp(email: email);
    if (!res.isSuccess) {
      _errorMessage = res.message;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> fetchProfile() async {
    if (!isLoggedIn) return;
    _isLoading = true;
    notifyListeners();

    final res = await _authRepository.getProfile();
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _user = res.data;
    } else {
      _errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _authRepository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      address: address,
    );
    _isLoading = false;

    if (res.isSuccess) {
      if (res.data != null) {
        _user = res.data;
      }
      notifyListeners();
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _token = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
