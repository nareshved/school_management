import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _pendingHomework = 0;
  int _unreadNotices = 0;
  double _attendancePercentage = 0.0;

  bool get isLoading => _isLoading;
  int get pendingHomework => _pendingHomework;
  int get unreadNotices => _unreadNotices;
  double get attendancePercentage => _attendancePercentage;

  Future<void> loadDashboardData(String classId, String studentId) async {
    // Just a basic outline, real logic calls Supabase
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      
            // Get pending homework
            final hwResponse = await Supabase.instance.client
                .from('homework')
                .select('id')
                .eq('class_id', classId)
                .gte('due_date', now.toIso8601String());
            _pendingHomework = hwResponse.length;

      // Get attendance percentage
      final attResponse = await Supabase.instance.client
          .from('attendance')
          .select('status')
          .eq('student_id', studentId);
      
      if (attResponse.isNotEmpty) {
        int present = attResponse.where((r) => r['status'] == 'present').length;
        _attendancePercentage = (present / attResponse.length) * 100;
      }

      // Get notices (assuming standard target_type matching)
      final noticeResponse = await Supabase.instance.client
          .from('notices')
          .select('id')
          .inFilter('target_type', ['all', 'student']);
      _unreadNotices = noticeResponse.length; // Can be simplified

    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
