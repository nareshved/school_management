import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/filter_chips.dart';
import 'add_edit_student.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  String _searchQuery = '';
  String _selectedClass = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    // Generate filter options
    final classes = ['All', ...provider.classes.map((c) => '${c['name']}-${c['section']}')];

    // Filter students
    final filteredStudents = provider.students.where((s) {
      final matchesSearch = s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.rollNumber != null && s.rollNumber!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesClass = _selectedClass == 'All' || s.displayClass == _selectedClass;
      return matchesSearch && matchesClass;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Student Directory', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, size: 24.w),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(classes),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStudentList(filteredStudents, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditStudentScreen(classes: provider.classes),
            ),
          );
        },
        icon: Icon(Icons.person_add_rounded, size: 24.w),
        label: Text('Add Student', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildSearchAndFilter(List<String> classes) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: Icon(Icons.search_rounded, size: 20.w),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 20.w),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: FilterChips(
              options: classes,
              selectedOption: _selectedClass,
              onSelected: (val) => setState(() => _selectedClass = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<dynamic> students, StudentProvider provider) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 64.w, color: AppColors.outline),
            SizedBox(height: 16.h),
            Text(
              'No students found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16.sp,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
      itemCount: students.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final student = students[index];
        return CustomCard(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  student.fullName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildBadge(Icons.class_rounded, student.displayClass ?? 'Unassigned', AppColors.secondary),
                        SizedBox(width: 8.w),
                        _buildBadge(Icons.numbers_rounded, 'Roll: ${student.rollNumber ?? '-'}', AppColors.tertiary),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 24.w),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditStudentScreen(
                          student: student,
                          classes: provider.classes,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Delete Student', style: TextStyle(fontSize: 20.sp)),
                        content: Text('Are you sure you want to remove ${student.fullName}?', style: TextStyle(fontSize: 14.sp)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 14.sp)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await provider.deleteStudent(student.id!);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'view', child: Text('View Profile', style: TextStyle(fontSize: 14.sp))),
                  PopupMenuItem(value: 'edit', child: Text('Edit Info', style: TextStyle(fontSize: 14.sp))),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
