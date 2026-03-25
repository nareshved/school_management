import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/homework_provider.dart';
import '../../widgets/custom_card.dart';

class HomeworkView extends StatefulWidget {
  const HomeworkView({super.key});

  @override
  State<HomeworkView> createState() => _HomeworkViewState();
}

class _HomeworkViewState extends State<HomeworkView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomework();
    });
  }

  Future<void> _loadHomework() async {
    final auth = context.read<AuthProvider>();
    final classId = auth.currentStudent?.classId;
    final studentId = auth.currentStudent?.id;
    if (classId != null && studentId != null) {
      await context.read<HomeworkProvider>().loadHomeworks(
            classId.toString(),
            studentId: studentId.toString(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeworkProvider>();
    final studentId = context.read<AuthProvider>().currentStudent?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHomework,
              child: ListView.builder(
                padding: EdgeInsets.all(24.w),
                itemCount: provider.homeworks.length,
                itemBuilder: (context, index) {
                  final hw = provider.homeworks[index];
                  final hwId = hw['id'].toString();
                  final subjectName = hw['subjects']['name'] ?? 'Subject';
                  final teacherName = hw['teachers']['full_name'] ?? 'Teacher';
                  final title = hw['title'] ?? 'Title';
                  final description = hw['description'] ?? '';
                  final dueDate = DateTime.parse(hw['due_date']);
                  final isOverdue = dueDate.isBefore(DateTime.now());
                  final isCompleted = provider.isCompleted(hwId);

                  return CustomCard(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                  ? Colors.green.withOpacity(0.1) 
                                  : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                isCompleted ? 'Completed' : subjectName,
                                style: TextStyle(
                                  color: isCompleted ? Colors.green : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Text(
                              'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                              style: TextStyle(
                                color: isOverdue && !isCompleted 
                                  ? AppColors.error 
                                  : AppColors.onSurfaceVariant,
                                fontWeight: (isOverdue && !isCompleted) ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? AppColors.onSurfaceVariant : null,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              child: Icon(Icons.person, size: 16.sp, color: AppColors.onSurface),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              teacherName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            if (!isCompleted)
                              FilledButton.tonal(
                                onPressed: () async {
                                  if (studentId != null) {
                                    try {
                                      await provider.markAsDone(studentId.toString(), hwId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Homework marked as done!')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  minimumSize: Size.zero,
                                  backgroundColor: AppColors.primaryContainer,
                                  foregroundColor: AppColors.primary,
                                ),
                                child: Text('Mark Done', style: TextStyle(fontSize: 12.sp)),
                              )
                            else
                              Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
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
