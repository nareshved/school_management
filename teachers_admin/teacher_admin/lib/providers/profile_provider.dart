import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  String? get teacherId => _profile?['id']?.toString();
  String? get fullName => _profile?['full_name'] as String?;
  String? get subjectName => _profile?['subjects']?['name'] as String?;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await SupabaseService.getTeacherProfileByUserId(userId);
    } catch (e) {
      // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
