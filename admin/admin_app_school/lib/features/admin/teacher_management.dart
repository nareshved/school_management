import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/custom_card.dart';
import 'add_edit_teacher.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    
    final filteredTeachers = provider.teachers.where((t) {
      return t.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Teacher Directory', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        children: [
          _buildSearchbar(),
          Expanded(
            child: provider.isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildTeacherList(filteredTeachers, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTeacherScreen(subjects: provider.subjects),
            ),
          );
        },
        icon: Icon(Icons.person_add_alt_1_rounded, size: 24.w),
        label: Text('Add Teacher', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildSearchbar() {
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: EdgeInsets.all(24.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search teachers...',
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
    );
  }

  Widget _buildTeacherList(List<dynamic> teachers, TeacherProvider provider) {
    if (teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 64.w, color: AppColors.outline),
            SizedBox(height: 16.h),
            Text(
              'No teachers found',
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
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
      itemCount: teachers.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final subjectName = teacher.displaySubject ?? 'Unassigned Subject';
        final classes = teacher.assignedClasses;
        
        return CustomCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Text(
                      teacher.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.secondary,
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
                          teacher.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded, size: 14.w, color: AppColors.onSurfaceVariant),
                            SizedBox(width: 4.w),
                            Text(
                              subjectName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 24.w),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditTeacherScreen(
                              teacher: teacher,
                              subjects: provider.subjects,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'view', child: Text('View Profile', style: TextStyle(fontSize: 14.sp))),
                      PopupMenuItem(value: 'edit', child: Text('Edit Info', style: TextStyle(fontSize: 14.sp))),
                    ],
                  ),
                ],
              ),
              if (classes.isNotEmpty) ...[
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 8.h),
                Text('Assigned Classes', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: classes.map<Widget>((c) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
