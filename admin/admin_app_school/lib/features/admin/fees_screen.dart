import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/fee_provider.dart';
import '../../widgets/custom_card.dart';
import 'record_payment.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeProvider>();

    final filteredFees = provider.fees.where((f) {
      if (_selectedFilter == 'All') return true;
      return f.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Fees Management', style: TextStyle(fontSize: 20.sp)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCollectionCard(provider),
                        SizedBox(height: 32.h),
                        _buildFilterTabs(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: filteredFees.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.w),
                              child: Text('No records found', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16.sp)),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final fee = filteredFees[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: _buildTransactionTile(fee),
                              );
                            },
                            childCount: filteredFees.length,
                          ),
                        ),
                ),
                SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordPaymentScreen()),
          );
        },
        icon: Icon(Icons.add_rounded, size: 24.w),
        label: Text('Record Payment', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildCollectionCard(FeeProvider provider) {
    final expected = provider.totalExpectedAmount;
    final collected = provider.totalCollectedAmount;
    final progress = expected > 0 ? (collected / expected) * 100 : 0.0;

    return CustomCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Text(
            'Monthly Collection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 160.h,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60.r,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.success,
                        value: collected > 0 ? collected : 1, // Prevent 0 radius
                        title: '',
                        radius: 20.r,
                      ),
                      PieChartSectionData(
                        color: AppColors.surfaceContainerHigh,
                        value: (expected - collected) > 0 ? (expected - collected) : 1,
                        title: '',
                        radius: 20.r,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 28.sp,
                            ),
                      ),
                      Text(
                        'Collected',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12.sp,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Collected', '\$${collected.toStringAsFixed(0)}', AppColors.success),
              _buildLegendItem('Pending', '\$${(expected - collected).toStringAsFixed(0)}', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 8.w),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(amount, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['All', 'Paid', 'Pending'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedFilter == tab;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = tab),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic fee) {
    final isPaid = fee.isPaid;
    final color = fee.statusColor;

    return CustomCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${fee.displayClass} • Roll ${fee.studentRoll ?? "-"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${fee.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPaid ? AppColors.onSurface : AppColors.error,
                      fontSize: 16.sp,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('MMM dd').format(fee.dueDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
