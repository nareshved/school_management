import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../services/supabase_service.dart';

class NoticeProvider extends ChangeNotifier {
  List<NoticeModel> _notices = [];
  bool _isLoading = true;

  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notices = await SupabaseService.getNotices();
    } catch (e) {
      // Log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNotice(NoticeModel notice) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SupabaseService.addNotice(notice);
      await loadData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
