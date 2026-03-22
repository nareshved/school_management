import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_card.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _selectedClass = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    await context.read<StudentProvider>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final teacherClasses = ['All', ...provider.classes.map((e) => e['name'] as String).toSet()];

    final filteredStudents = _selectedClass == 'All'
        ? provider.students
        : provider.students.where((s) => s.className == _selectedClass).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Class selector
                if (teacherClasses.length > 1)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      height: 48.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: teacherClasses.length,
                        itemBuilder: (context, index) {
                          final cls = teacherClasses[index];
                          final isSelected = _selectedClass == cls;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              label: Text(cls),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  _selectedClass = cls;
                                });
                              },
                              selectedColor: AppColors.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadStudents,
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64.w, color: AppColors.outline),
                                SizedBox(height: 16.h),
                                Text(
                                  'No students found',
                                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16.sp),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return CustomCard(
                                margin: EdgeInsets.only(bottom: 12.h),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primaryContainer,
                                    backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                                    child: student.avatarUrl == null
                                        ? Text(student.initials, style: const TextStyle(color: AppColors.primary))
                                        : null,
                                  ),
                                  title: Text(student.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                  subtitle: Text('Roll: ${student.rollNumber ?? "N/A"} | ${student.displayClass}', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${(student.attendancePercent ?? 0).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (student.attendancePercent ?? 0) < 75 ? AppColors.error : AppColors.success,
                                        ),
                                      ),
                                      Text('Att.', style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                ),
              ],
            ),
    );
  }
}
