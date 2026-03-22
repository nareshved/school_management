import 'package:flutter/material.dart';
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

  Future<void> login(String email, String password, String selectedRole) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await SupabaseService.signIn(email, password);
      if (user != null) {
        final profile = await SupabaseService.getUserProfile(user.id);
        if (profile?.role != selectedRole) {
          await SupabaseService.signOut();
          throw Exception('Unauthorized: Invalid role selection.');
        }
        _currentUser = profile;
      }
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
