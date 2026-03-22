import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_card.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
    });
  }

  Future<void> _loadAttendance() async {
    final studentId = context.read<AuthProvider>().currentStudent?.id;
    if (studentId != null) {
      await context.read<AttendanceProvider>().loadAttendance(studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final stats = provider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    CustomCard(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Text(
                            'Overall Attendance',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            height: 160.h,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50.r,
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.success,
                                    value: (stats['present'] ?? 0).toDouble(),
                                    title: '${stats['present']}',
                                    radius: 20.r,
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.error,
                                    value: (stats['absent'] ?? 0).toDouble(),
                                    title: '${stats['absent']}',
                                    radius: 20.r,
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLegendItem('Present', AppColors.success),
                              _buildLegendItem('Absent', AppColors.error),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    Text(
                      'Recent Records',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 16.h),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = provider.attendanceRecords[index];
                        final isPresent = record['status'] == 'present';
                        final dateStr = record['date'] as String;
                        final date = DateTime.parse(dateStr);

                        return CustomCard(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: (isPresent ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPresent ? Icons.check : Icons.close,
                                color: isPresent ? AppColors.success : AppColors.error,
                              ),
                            ),
                            title: Text(
                              DateFormat('EEEE, MMM d, yyyy').format(date),
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                            ),
                            subtitle: Text(
                              isPresent ? 'Present' : 'Absent',
                              style: TextStyle(
                                color: isPresent ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
