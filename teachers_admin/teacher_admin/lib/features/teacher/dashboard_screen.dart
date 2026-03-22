import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherDashboardProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async => context.read<TeacherDashboardProvider>().loadDashboardData(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(user?.email.split('@').first ?? 'Teacher'),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(provider),
                    SizedBox(height: 32.h),
                    _buildQuickActions(),
                    SizedBox(height: 32.h),
                    _buildMyClasses(provider),
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

  Widget _buildAppBar(String userName) {
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
              Text('Welcome, $userName', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: 24.w),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeroCard(TeacherDashboardProvider provider) {
    if (provider.isLoading) {
      return SizedBox(
        height: 160.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Schedule Overview',
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildHeroStat('${provider.assignedClasses}', 'Assigned\nClasses', Icons.class_),
              Container(width: 1, height: 40.h, color: Colors.white24, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              _buildHeroStat('${provider.activeHomeworks}', 'Active\nHomework', Icons.book),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 32.w),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
          ],
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
              _buildActionChip(Icons.how_to_reg, 'Mark Attendance', AppColors.primary),
              SizedBox(width: 12.w),
              _buildActionChip(Icons.upload_file, 'Upload Homework', AppColors.secondary),
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

  Widget _buildMyClasses(TeacherDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Classes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
        SizedBox(height: 16.h),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.todayClasses.isEmpty)
          const Text('No classes assigned')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.todayClasses.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final c = provider.todayClasses[index];
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        c['class_name'] ?? 'C',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class ${c['class_name']} - Section ${c['section']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                          Text('Subject ID: ${c['subject_id'] ?? 'N/A'}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
