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
      userId: widget.teacher?.userId, // usually mapped to auth user if they log in
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      subjectId: _selectedSubjectId,
      isActive: widget.teacher?.isActive ?? true,
    );

    try {
      await provider.addOrUpdateTeacher(teacher);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.teacher == null ? 'Teacher added successfully' : 'Teacher updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TeacherProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'Add New Teacher' : 'Edit Teacher', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
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
                        ? Icon(Icons.person, size: 50.w, color: AppColors.secondary)
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
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            
            Text('Professional Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedSubjectId,
              decoration: const InputDecoration(labelText: 'Primary Subject', prefixIcon: Icon(Icons.menu_book_rounded)),
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
                    decoration: const InputDecoration(labelText: 'Qualification', prefixIcon: Icon(Icons.school_outlined)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _experienceCtrl,
                    decoration: const InputDecoration(labelText: 'Experience (Years)', prefixIcon: Icon(Icons.work_outline)),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            
            Text('Contact Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 48.h),
            
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveTeacher,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                child: isSaving 
                    ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.teacher == null ? 'Add Teacher' : 'Save Changes', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
