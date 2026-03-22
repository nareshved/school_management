import 'package:flutter/material.dart';
import '../../models/fee_model.dart';
import '../../services/supabase_service.dart';

class FeeProvider extends ChangeNotifier {
  List<FeeModel> _fees = [];
  bool _isLoading = true;

  List<FeeModel> get fees => _fees;
  bool get isLoading => _isLoading;

  double get totalExpectedAmount {
    double total = 0;
    for (var f in _fees) {
      total += f.amount;
    }
    return total;
  }

  double get totalCollectedAmount {
    double collected = 0;
    for (var f in _fees) {
      if (f.status == 'paid') collected += f.amount;
    }
    return collected;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _fees = await SupabaseService.getFees();
    } catch (e) {
      // Log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFee(FeeModel fee) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SupabaseService.addFee(fee);
      await loadData();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
