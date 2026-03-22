import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_card.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final students = provider.students;
    final loading = provider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Daily Attendance', style: TextStyle(fontSize: 20.sp)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: provider.selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                provider.setDate(date);
              }
            },
            icon: Icon(Icons.calendar_today_rounded, size: 18.w, color: AppColors.primary),
            label: Text(
              DateFormat('MMM dd').format(provider.selectedDate),
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          _buildClassSelector(provider),
          if (provider.selectedClassId != null) ...[
            _buildStatsCards(provider.totalStudents, provider.presentCount, provider.absentCount),
            SizedBox(height: 16.h),
            _buildBulkActions(provider),
          ],
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : provider.selectedClassId == null
                    ? _buildSelectClassPrompt()
                    : students.isEmpty
                        ? const Center(child: Text('No students found for this class'))
                        : _buildStudentList(provider),
          ),
        ],
      ),
      floatingActionButton: provider.selectedClassId != null && !loading && students.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _handleSave(provider),
              icon: Icon(Icons.save_rounded, size: 24.w),
              label: Text('Save Attendance', style: TextStyle(fontSize: 14.sp)),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Future<void> _handleSave(AttendanceProvider provider) async {
    try {
      await provider.saveAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildSelectClassPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64.w, color: AppColors.outline),
          SizedBox(height: 16.h),
          Text(
            'Select a class to mark attendance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16.sp,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(AttendanceProvider provider) {
    if (provider.isLoading && provider.classes.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    }

    return Container(
      height: 80.h,
      color: AppColors.surfaceContainerLowest,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        scrollDirection: Axis.horizontal,
        itemCount: provider.classes.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final c = provider.classes[index];
          final isSelected = provider.selectedClassId == c['id'].toString();
          return InkWell(
            onTap: () => provider.setClass(c['id'].toString()),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  '${c['name']}-${c['section']}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(int total, int present, int absent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(child: _buildStat('Total', total.toString(), AppColors.primary)),
          SizedBox(width: 12.w),
          Expanded(child: _buildStat('Present', present.toString(), AppColors.success)),
          SizedBox(width: 12.w),
          Expanded(child: _buildStat('Absent', absent.toString(), AppColors.error)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return CustomCard(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 24.sp)),
          SizedBox(height: 4.h),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildBulkActions(AttendanceProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Mark All:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => provider.markAll('present'),
                icon: Icon(Icons.check_circle_outline, color: AppColors.success, size: 20.w),
                label: Text('Present', style: TextStyle(color: AppColors.success, fontSize: 14.sp)),
              ),
              TextButton.icon(
                onPressed: () => provider.markAll('absent'),
                icon: Icon(Icons.highlight_off, color: AppColors.error, size: 20.w),
                label: Text('Absent', style: TextStyle(color: AppColors.error, fontSize: 14.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(AttendanceProvider provider) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
      itemCount: provider.students.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final student = provider.students[index];
        final id = student.id.toString();
        final status = provider.attendanceMap[id];

        Color getStatusColor() {
          if (status == 'present') return AppColors.success;
          if (status == 'absent') return AppColors.error;
          if (status == 'late') return AppColors.tertiary;
          return AppColors.outlineVariant;
        }

        return CustomCard(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primaryContainer,
                child: Text(student.fullName.isNotEmpty ? student.fullName[0] : '?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    Text('Roll: ${student.rollNumber ?? '-'}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: getStatusColor()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBtn(provider, id, 'present', Icons.check, status == 'present' ? AppColors.success : Colors.transparent),
                    _buildStatusBtn(provider, id, 'absent', Icons.close, status == 'absent' ? AppColors.error : Colors.transparent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBtn(AttendanceProvider provider, String id, String type, IconData icon, Color bgColor) {
    final isSelected = bgColor != Colors.transparent;
    return InkWell(
      onTap: () => provider.markStudent(id, type),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.w,
          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
