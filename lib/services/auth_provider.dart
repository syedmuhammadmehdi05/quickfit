import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await _authService.getUser(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      _setLoading(false);
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? employeeId,
    String? coachId,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        employeeId: employeeId,
        coachId: coachId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void refreshUser() async {
    if (_currentUser != null) {
      _currentUser = await _authService.getUser(_currentUser!.uid);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('invalid-employee-id')) {
      return 'This Employee ID is not registered. Contact your administrator.';
    } else if (raw.contains('employee-id-used')) {
      return 'This Employee ID has already been used.';
    } else if (raw.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    } else if (raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    } else if (raw.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (raw.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    } else if (raw.contains('network-request-failed')) {
      return 'No internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
