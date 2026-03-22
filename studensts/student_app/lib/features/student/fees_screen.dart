import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fee_provider.dart';
import '../../widgets/custom_card.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFees();
    });
  }

  Future<void> _loadFees() async {
    final studentId = context.read<AuthProvider>().currentStudent?.id;
    if (studentId != null) {
      await context.read<FeeProvider>().loadFees(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Records'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFees,
              child: ListView.builder(
                padding: EdgeInsets.all(24.w),
                itemCount: provider.fees.length,
                itemBuilder: (context, index) {
                  final fee = provider.fees[index];
                  final isPaid = fee.status == 'paid';
                  
                  return CustomCard(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.w),
                      leading: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: (isPaid ? AppColors.success : AppColors.pending).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPaid ? Icons.check_circle : Icons.pending,
                          color: isPaid ? AppColors.success : AppColors.pending,
                        ),
                      ),
                      title: Text(
                        '₹${fee.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        fee.feeType,
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: (isPaid ? AppColors.success : AppColors.pending).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isPaid ? 'PAID' : 'PENDING',
                              style: TextStyle(
                                color: isPaid ? AppColors.success : AppColors.pending,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            DateFormat('MMM d, yyyy').format(fee.dueDate ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
