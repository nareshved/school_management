import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async => context.read<DashboardProvider>().loadDashboardData(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(provider),
                    SizedBox(height: 32.h),
                    _buildQuickActions(),
                    SizedBox(height: 32.h),
                    _buildRecentActivity(provider),
                    // Add some bottom padding
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.school, color: AppColors.primary, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart School', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
              Text('Admin Dashboard', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: 24.w),
          onPressed: () {}, // Notifications 
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardProvider provider) {
    if (provider.isLoading) {
      return SizedBox(
        height: 200.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = provider.stats;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.w,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        StatCard(
          title: 'Total Students',
          value: stats['totalStudents'].toString(),
          icon: Icons.people_alt_rounded,
          iconColor: AppColors.primary,
        ),
        StatCard(
          title: 'Total Teachers',
          value: stats['totalTeachers'].toString(),
          icon: Icons.badge_rounded,
          iconColor: AppColors.secondary,
        ),
        StatCard(
          title: 'Collected Fees',
          value: '\$${(stats['collectedFees'] as num).toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.success,
        ),
        StatCard(
          title: 'Pending Tasks',
          value: stats['pendingTasks'].toString(),
          icon: Icons.pending_actions_rounded,
          iconColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionChip(Icons.person_add_rounded, 'Add Student', AppColors.primary),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.person_add_alt_1_rounded, 'Add Teacher', AppColors.secondary),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.payment_rounded, 'Collect Fees', AppColors.success),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.campaign_rounded, 'Send Notice', AppColors.tertiary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            TextButton(
              onPressed: () {},
              child: Text('See All', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.activities.isEmpty)
          const Text('No recent activities')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.activities.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final act = provider.activities[index];
              return _buildActivityItem(
                act['action'],
                act['description'],
                DateTime.parse(act['created_at']),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String desc, DateTime time) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: AppColors.primary, size: 20.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                SizedBox(height: 4.h),
                Text(desc, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
              ],
            ),
          ),
          Text(
            DateFormat.jm().format(time),
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
