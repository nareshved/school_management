import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  int _assignedClasses = 0;
  int _activeHomeworks = 0;
  List<Map<String, dynamic>> _todayClasses = [];
  bool _isLoading = true;

  int get assignedClasses => _assignedClasses;
  int get activeHomeworks => _activeHomeworks;
  List<Map<String, dynamic>> get todayClasses => _todayClasses;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final teacherId = SupabaseService.currentUserId;
      if (teacherId == null) return;

      final classesData = await SupabaseService.getTeacherClasses(teacherId);
      final classIds = classesData.map((e) => e['id']).toList();
      
      _assignedClasses = classesData.length;
      
      // For demo purposes, we will treat all assigned classes as "Today's Classes"
      _todayClasses = classesData;

      if (classIds.isNotEmpty) {
         // Count total active homeworks for the teacher's classes
         int totalHw = 0;
         for (var cid in classIds) {
           final hws = await SupabaseService.getHomework(classId: cid);
           totalHw += hws.length;
         }
         _activeHomeworks = totalHw;
      }
    } catch (e) {
      // Ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
