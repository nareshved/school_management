import 'package:flutter/material.dart';
import '../../models/fee_model.dart';
import '../../services/supabase_service.dart';

class FeeProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<FeeModel> _fees = [];

  bool get isLoading => _isLoading;
  List<FeeModel> get fees => _fees;

  Future<void> loadFees(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _fees = await SupabaseService.getFees(studentId: studentId);
    } catch (e) {
      debugPrint('Error loading fees: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
