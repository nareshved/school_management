import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../models/teacher_model.dart';
import '../../providers/teacher_provider.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final TeacherModel? teacher;
  final List<Map<String, dynamic>> subjects;

  const AddEditTeacherScreen({super.key, this.teacher, required this.subjects});

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _qualificationCtrl;
  late TextEditingController _experienceCtrl;

  String? _selectedSubjectId;
  final Set<String> _selectedClassIds = {};

  @override
  void initState() {
    super.initState();
    final t = widget.teacher;
    _fullNameCtrl = TextEditingController(text: t?.fullName ?? '');
    _emailCtrl = TextEditingController(text: t?.email ?? '');
    _phoneCtrl = TextEditingController(text: t?.phone ?? '');
    _qualificationCtrl = TextEditingController(text: '');
    _experienceCtrl = TextEditingController(text: '');
    _selectedSubjectId = t?.subjectId;

    // Pre-populate assigned classes when editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeacherProvider>();
      if (t != null && t.assignedClasses.isNotEmpty) {
        for (final cls in provider.classes) {
          final label = '${cls['name']}-${cls['section']}';
          if (t.assignedClasses.contains(label)) {
            setState(() => _selectedClassIds.add(cls['id'].toString()));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TeacherProvider>();

    final teacher = TeacherModel(
      id: widget.teacher?.id,
      userId: widget.teacher?.userId,
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      subjectId: _selectedSubjectId,
      isActive: widget.teacher?.isActive ?? true,
    );

    try {
      await provider.addOrUpdateTeacher(teacher, _selectedClassIds.toList());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.teacher == null
                ? 'Teacher added successfully'
                : 'Teacher updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final isSaving = provider.isLoading;
    final classes = provider.classes;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.teacher == null ? 'Add New Teacher' : 'Edit Teacher',
          style: TextStyle(fontSize: 20.sp),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: TextButton(
              onPressed: isSaving ? null : _saveTeacher,
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.secondaryContainer,
                    backgroundImage: widget.teacher?.avatarUrl != null
                        ? NetworkImage(widget.teacher!.avatarUrl!)
                        : null,
                    child: widget.teacher?.avatarUrl == null
                        ? Icon(Icons.person_rounded,
                            size: 50.w, color: AppColors.secondary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.camera_alt, color: Colors.white, size: 18.w),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // ─── Section: Professional Info ───
            _sectionHeader(Icons.badge_outlined, 'Professional Information',
                AppColors.primary),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: _selectedSubjectId,
              decoration: const InputDecoration(
                labelText: 'Primary Subject',
                prefixIcon: Icon(Icons.menu_book_rounded),
              ),
              items: widget.subjects.map((s) {
                return DropdownMenuItem(
                  value: s['id'].toString(),
                  child: Text(s['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedSubjectId = val),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qualificationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Qualification',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _experienceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Exp. (Years)',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),

            // ─── Section: Contact Info ───
            _sectionHeader(
                Icons.contact_phone_outlined, 'Contact Information', AppColors.secondary),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 28.h),

            // ─── Section: Assign Classes ───
            _sectionHeader(
                Icons.class_outlined, 'Assign Classes', AppColors.tertiary),
            SizedBox(height: 8.h),
            if (classes.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: Text('No classes available',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                ),
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: classes.map((cls) {
                  final id = cls['id'].toString();
                  final label = '${cls['name']}-${cls['section']}';
                  final isSelected = _selectedClassIds.contains(id);
                  return FilterChip(
                    label: Text(label,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurface)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedClassIds.add(id);
                        } else {
                          _selectedClassIds.remove(id);
                        }
                      });
                    },
                    selectedColor: AppColors.tertiary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    side: BorderSide(
                        color: isSelected
                            ? AppColors.tertiary
                            : AppColors.outlineVariant),
                  );
                }).toList(),
              ),
            SizedBox(height: 40.h),

            // Save Button
            SizedBox(
              height: 56.h,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveTeacher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: isSaving
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(
                        widget.teacher == null
                            ? Icons.person_add_alt_1_rounded
                            : Icons.save_rounded,
                        size: 20.w),
                label: Text(
                  widget.teacher == null ? 'Add Teacher' : 'Save Changes',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 18.w),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
