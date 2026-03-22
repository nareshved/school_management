import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../services/supabase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String? _selectedClassId;
  
  List<Map<String, dynamic>> _classes = [];
  List<StudentModel> _students = [];
  Map<String, String> _attendanceMap = {}; 
  
  bool _isLoading = true;
  bool _isSaving = false;

  DateTime get selectedDate => _selectedDate;
  String? get selectedClassId => _selectedClassId;
  List<Map<String, dynamic>> get classes => _classes;
  List<StudentModel> get students => _students;
  Map<String, String> get attendanceMap => _attendanceMap;
  
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  int get totalStudents => _students.length;
  int get presentCount => _attendanceMap.values.where((s) => s == 'present').length;
  int get absentCount => _attendanceMap.values.where((s) => s == 'absent').length;

  Future<void> loadClasses() => loadData();

  void markAll(String status) {
    for (var student in _students) {
      if (student.id != null) _attendanceMap[student.id!] = status;
    }
    notifyListeners();
  }

  void markStudent(String studentId, String status) {
    updateAttendance(studentId, status);
  }

  Future<void> loadData() async {
    final teacherId = SupabaseService.currentUserId;
    if (teacherId == null) return;
    
    if (_classes.isEmpty) {
      _classes = await SupabaseService.getTeacherClasses(teacherId);
      if (_classes.isNotEmpty) {
        _selectedClassId = _classes.first['id'];
      }
    }
    
    if (_selectedClassId != null) {
      await _loadAttendanceForClass();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDate(DateTime date) async {
    _selectedDate = date;
    await _loadAttendanceForClass();
  }

  Future<void> setClass(String classId) async {
    _selectedClassId = classId;
    await _loadAttendanceForClass();
  }

  Future<void> _loadAttendanceForClass() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allStudents = await SupabaseService.getStudents();
      _students = allStudents.where((s) => s.classId == _selectedClassId).toList();
      
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final records = await SupabaseService.getAttendance(classId: _selectedClassId!, date: dateStr);
      
      final newMap = <String, String>{};
      for (var student in _students) {
        final record = records.firstWhere(
          (r) => r['student_id'] == student.id,
          orElse: () => {'status': 'present'}, 
        );
        newMap[student.id!] = record['status'];
      }
      _attendanceMap = newMap;
    } catch (e) {
      // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateAttendance(String studentId, String status) {
    _attendanceMap[studentId] = status;
    notifyListeners();
  }

  Future<void> saveAttendance() async {
    if (_selectedClassId == null || _students.isEmpty) return;
    
    _isSaving = true;
    notifyListeners();
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final records = _attendanceMap.entries.map((e) => {
        'student_id': e.key,
        'class_id': _selectedClassId,
        'date': dateStr,
        'status': e.value,
      }).toList();
      
      await SupabaseService.markAttendance(records);
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
