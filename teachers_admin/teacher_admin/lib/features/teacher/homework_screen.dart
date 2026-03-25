import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/homework_provider.dart';
import '../../widgets/custom_card.dart';
import '../../services/supabase_service.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String? _selectedClassId;
  List<Map<String, dynamic>> _classes = [];
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final tid = SupabaseService.currentUserId;
      if (tid != null) {
        final classes = await SupabaseService.getTeacherClasses(tid);
        if (mounted) {
          setState(() {
            _classes = classes;
            if (_classes.isNotEmpty) {
              _selectedClassId = _classes.first['id'].toString();
            }
          });
          if (_selectedClassId != null) {
            context.read<HomeworkProvider>().loadHomework(_selectedClassId!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading classes: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingClasses = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeworkProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Homework', style: TextStyle(fontSize: 20.sp)),
      ),
      body: _isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildClassSelector(),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.homeworkList.isEmpty
                          ? const Center(child: Text('No homework assigned yet'))
                          : ListView.separated(
                              padding: EdgeInsets.all(24.w),
                              itemCount: provider.homeworkList.length,
                              separatorBuilder: (context, index) => SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                final hw = provider.homeworkList[index];
                                final dueDate = DateTime.tryParse(hw['due_date'] ?? '');
                                final dateStr = dueDate != null ? DateFormat('MMM dd, yyyy').format(dueDate) : 'N/A';
                                return CustomCard(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              hw['title'] ?? 'Untitled',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit_outlined, size: 20.w, color: AppColors.primary),
                                                onPressed: () => _showAddHomeworkDialog(context, editHomework: hw),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, size: 20.w, color: AppColors.error),
                                                onPressed: () => _handleDelete(provider, hw['id'].toString()),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        hw['description'] ?? '',
                                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp),
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorContainer,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          'Due: $dateStr',
                                          style: TextStyle(color: AppColors.error, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: _selectedClassId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddHomeworkDialog(context),
              icon: Icon(Icons.add, size: 24.w),
              label: Text('Assign', style: TextStyle(fontSize: 14.sp)),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  void _handleDelete(HomeworkProvider provider, String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Homework'),
        content: const Text('Are you sure you want to delete this homework?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedClassId != null) {
      try {
        await provider.deleteHomework(id, _selectedClassId!);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Homework deleted successfully'), backgroundColor: AppColors.success),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildClassSelector() {
    if (_classes.isEmpty) return const SizedBox();

    return Container(
      height: 80.h,
      color: AppColors.surfaceContainerLowest,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final c = _classes[index];
          final isSelected = _selectedClassId == c['id'].toString();
          return InkWell(
            onTap: () {
              setState(() => _selectedClassId = c['id'].toString());
              context.read<HomeworkProvider>().loadHomework(_selectedClassId!);
            },
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

  void _showAddHomeworkDialog(BuildContext context, {Map<String, dynamic>? editHomework}) {
    final titleCtrl = TextEditingController(text: editHomework?['title']);
    final descCtrl = TextEditingController(text: editHomework?['description']);
    DateTime? selectedDate = editHomework != null 
        ? DateTime.tryParse(editHomework['due_date'] ?? '') ?? DateTime.now().add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24.w,
                right: 24.w,
                top: 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(editHomework != null ? 'Edit Homework' : 'Assign Homework', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate!,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setModalState(() => selectedDate = date);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) return;
                        
                        final provider = context.read<HomeworkProvider>();
                        final classData = _classes.firstWhere((c) => c['id'].toString() == _selectedClassId);
                        final subjectId = classData['subject_id']?.toString() ?? 'unknown';

                        final sm = ScaffoldMessenger.of(context);
                        try {
                          if (editHomework != null) {
                            await provider.updateHomework(
                              editHomework['id'].toString(),
                              titleCtrl.text,
                              descCtrl.text,
                              selectedDate!.toIso8601String().split('T')[0],
                              _selectedClassId!,
                              subjectId,
                            );
                            sm.showSnackBar(
                              const SnackBar(content: Text('Homework updated!'), backgroundColor: AppColors.success),
                            );
                          } else {
                            await provider.addHomework(
                              titleCtrl.text,
                              descCtrl.text,
                              selectedDate!.toIso8601String().split('T')[0],
                              _selectedClassId!,
                              subjectId,
                            );
                            sm.showSnackBar(
                              const SnackBar(content: Text('Homework assigned!'), backgroundColor: AppColors.success),
                            );
                          }
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          sm.showSnackBar(
                            SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(editHomework != null ? 'Update' : 'Publish', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
