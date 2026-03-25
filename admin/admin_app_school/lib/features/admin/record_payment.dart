import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/fee_model.dart';
import '../../providers/fee_provider.dart';
import '../../providers/student_provider.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStudentId;
  String _selectedFeeType = AppConstants.feeTypes.first;
  final _amountCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<FeeProvider>();
    final fee = FeeModel(
      studentId: _selectedStudentId!,
      amount: double.parse(_amountCtrl.text.trim()),
      feeType: _selectedFeeType,
      status: _status,
      dueDate: _dueDate,
      paidDate: _status == 'paid' ? DateTime.now() : null,
    );

    try {
      await provider.addFee(fee);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = context.watch<StudentProvider>();
    final isSaving = context.watch<FeeProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Record Payment', style: TextStyle(fontSize: 20.sp)),
      ),
      body: studentProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(24.w),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStudentId,
                    decoration: const InputDecoration(labelText: 'Student *', prefixIcon: Icon(Icons.person_outline)),
                    items: studentProv.students.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.fullName} (${s.displayClass})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStudentId = val),
                    validator: (v) => v == null ? 'Select a student' : null,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFeeType,
                    decoration: const InputDecoration(labelText: 'Fee Type *', prefixIcon: Icon(Icons.category_outlined)),
                    items: AppConstants.feeTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFeeType = val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(labelText: 'Amount *', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () async {
                      final time = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (time != null) setState(() => _dueDate = time);
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          hintText: DateFormat('MMM d, yyyy').format(_dueDate),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.info_outline)),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  SizedBox(height: 48.h),
                  SizedBox(
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _recordPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      child: isSaving
                          ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Record Payment', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
