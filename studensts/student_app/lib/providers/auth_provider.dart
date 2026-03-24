import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  UserModel? _currentUser;
  StudentModel? _currentStudent;

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  StudentModel? get currentStudent => _currentStudent;

  AuthProvider() {
    _initSession();
  }

  Future<void> _initSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _loadUserRole();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      _currentUser = await SupabaseService.getUserProfile(userId);
      if (_currentUser?.role == AppConstants.roleStudent) {
        // Fetch student details from students table
        final studentData = await Supabase.instance.client
            .from('students')
            .select()
            .eq('user_id', _currentUser!.id)
            .single();
        _currentStudent = StudentModel.fromJson(studentData);
      }
    } catch (e) {
      debugPrint('Error loading role: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _loadUserRole();

      if (_currentUser?.role != AppConstants.roleStudent) {
        await Supabase.instance.client.auth.signOut();
        _currentUser = null;
        _currentStudent = null;
        throw Exception('Access denied. Expected student account.');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String fullName, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await SupabaseService.signUp(email, password, fullName, role);
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
    _currentStudent = null;
    _isLoading = false;
    notifyListeners();
  }
}
