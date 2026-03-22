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
    final classId = context.read<AuthProvider>().currentStudent?.classId;
    if (classId != null) {
      await context.read<HomeworkProvider>().loadHomeworks(classId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeworkProvider>();

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
                  final subjectName = hw['subjects']['name'] ?? 'Subject';
                  final teacherName = hw['teachers']['full_name'] ?? 'Teacher';
                  final title = hw['title'] ?? 'Title';
                  final description = hw['description'] ?? '';
                  final dueDate = DateTime.parse(hw['due_date']);
                  final isOverdue = dueDate.isBefore(DateTime.now());

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
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                subjectName,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            Text(
                              'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                              style: TextStyle(
                                color: isOverdue ? AppColors.error : AppColors.onSurfaceVariant,
                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
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
                            FilledButton.tonal(
                              onPressed: () {
                                // TODO: Navigate to detail/submission screen
                              },
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                minimumSize: Size.zero,
                              ),
                              child: Text('View Details', style: TextStyle(fontSize: 12.sp)),
                            ),
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
