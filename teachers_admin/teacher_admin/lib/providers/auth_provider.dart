import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        _currentUser = await SupabaseService.getUserProfile(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await SupabaseService.signIn(email, password);
      if (user != null) {
        if (user.role != AppConstants.roleTeacher) {
          await SupabaseService.signOut();
          throw Exception('Access Denied: Teacher privileges required.');
        }
        _currentUser = user;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String fullName, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await SupabaseService.signUp(email, password, fullName, role);
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
