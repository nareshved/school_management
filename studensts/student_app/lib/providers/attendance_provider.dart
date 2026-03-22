import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _attendanceRecords = [];
  Map<String, dynamic> _stats = {'present': 0, 'absent': 0, 'total': 0};

  bool get isLoading => _isLoading;
  List<dynamic> get attendanceRecords => _attendanceRecords;
  Map<String, dynamic> get stats => _stats;

  Future<void> loadAttendance(String studentId, {DateTime? month}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = Supabase.instance.client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .order('date', ascending: false);
          
      _attendanceRecords = await query;
      
      int present = _attendanceRecords.where((r) => r['status'] == 'present').length;
      int absent = _attendanceRecords.where((r) => r['status'] == 'absent').length;
      
      _stats = {
        'present': present,
        'absent': absent,
        'total': _attendanceRecords.length,
      };
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
