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
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
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
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fee.feeType,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '₹${fee.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                          ],
                        ),
                        Divider(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPaid ? 'Paid on' : 'Due Date',
                                  style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant),
                                ),
                                Text(
                                  DateFormat('MMM d, yyyy').format(
                                    isPaid ? (fee.paidDate ?? DateTime.now()) : (fee.dueDate ?? DateTime.now()),
                                  ),
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (!isPaid)
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment gateway integration coming soon!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Pay Now'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
