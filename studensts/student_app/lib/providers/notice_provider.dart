import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../services/supabase_service.dart';

class NoticeProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<NoticeModel> _notices = [];

  bool get isLoading => _isLoading;
  List<NoticeModel> get notices => _notices;

  Future<void> loadNotices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allNotices = await SupabaseService.getNotices();
      // Filter for 'all' or 'student'
      _notices = allNotices.where((n) {
        final lowerTarget = n.targetType.toLowerCase();
        return lowerTarget == 'all' || lowerTarget == 'student';
      }).toList();
    } catch (e) {
      debugPrint('Error loading notices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
