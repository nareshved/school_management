import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  final void Function(int)? onNavigate;
  const StudentDashboardScreen({super.key, this.onNavigate});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final student = auth.currentStudent;
    if (student != null) {
      final classId = student.classId ?? '';
      final studentId = student.id ?? '';
      if (classId.isNotEmpty && studentId.isNotEmpty) {
        await context
            .read<DashboardProvider>()
            .loadDashboardData(classId, studentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final student = auth.currentStudent;
    final user = auth.currentUser;

    if (student == null || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120.h,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
                title: Text(
                  'Good Morning,\n${student.fullName.split(' ').first}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -30.w,
                      top: -10.h,
                      child: Icon(
                        Icons.school,
                        size: 150.w,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
                SizedBox(width: 8.w),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Overview Card
                    CustomCard(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundColor: AppColors.primaryContainer,
                            backgroundImage: student.avatarUrl != null
                                ? NetworkImage(student.avatarUrl!)
                                : null,
                            child: student.avatarUrl == null
                                ? Icon(Icons.person,
                                    size: 32.sp, color: AppColors.primary)
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  student.className != null
                                      ? 'Class ${student.className}-${student.section ?? 'A'}'
                                      : 'Class Not Assigned',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Roll No: ${student.rollNumber ?? '-'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.amber[700], size: 16.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'Gold',
                                  style: TextStyle(
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.bold,
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

                    // Quick Stats
                    Text(
                      'Overview',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    
                    if (dashboard.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Attendance',
                              value: '${dashboard.attendancePercentage.toStringAsFixed(1)}%',
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: StatCard(
                              title: 'Pending H/W',
                              value: '${dashboard.pendingHomework}',
                              icon: Icons.assignment_late_outlined,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 28.h),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.w,
                      childAspectRatio: 2.4,
                      children: [
                        _buildActionTile(
                          Icons.calendar_month_outlined,
                          'My Attendance',
                          AppColors.primary,
                          () => widget.onNavigate?.call(1),
                        ),
                        _buildActionTile(
                          Icons.assignment_outlined,
                          'Homework',
                          AppColors.secondary,
                          () => widget.onNavigate?.call(2),
                        ),
                        _buildActionTile(
                          Icons.payments_outlined,
                          'My Fees',
                          AppColors.success,
                          () => widget.onNavigate?.call(3),
                        ),
                        _buildActionTile(
                          Icons.campaign_outlined,
                          'Notices',
                          AppColors.tertiary,
                          () => widget.onNavigate?.call(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.w),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
