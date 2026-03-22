import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'totalTeachers': 0,
    'totalFees': 0.0,
    'collectedFees': 0.0,
    'pendingTasks': 0,
  };
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  Map<String, dynamic> get stats => _stats;
  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedStats = await SupabaseService.getDashboardStats();
      final fetchedActivities = await SupabaseService.getRecentActivities(limit: 5);
      
      _stats = fetchedStats;
      _activities = fetchedActivities;
    } catch (e) {
      // Handle error gracefully
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
