import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  final StudentModel? student;
  final List<Map<String, dynamic>> classes;

  const AddEditStudentScreen({super.key, this.student, required this.classes});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameCtrl;
  late TextEditingController _rollNumberCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _guardianNameCtrl;
  late TextEditingController _guardianPhoneCtrl;
  late TextEditingController _addressCtrl;
  
  String? _selectedClassId;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _fullNameCtrl = TextEditingController(text: s?.fullName ?? '');
    _rollNumberCtrl = TextEditingController(text: s?.rollNumber ?? '');
    _dobCtrl = TextEditingController(text: s?.dateOfBirth?.toIso8601String().split('T').first ?? '');
    _guardianNameCtrl = TextEditingController(text: s?.guardianName ?? '');
    _guardianPhoneCtrl = TextEditingController(text: s?.guardianPhone ?? '');
    _addressCtrl = TextEditingController(text: s?.addressStreet ?? '');
    
    _selectedClassId = s?.classId;
    if (s?.gender != null) {
      _selectedGender = s!.gender!;
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _rollNumberCtrl.dispose();
    _dobCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<StudentProvider>();
    
    final student = StudentModel(
      id: widget.student?.id,
      fullName: _fullNameCtrl.text.trim(),
      classId: _selectedClassId,
      rollNumber: _rollNumberCtrl.text.trim().isEmpty ? null : _rollNumberCtrl.text.trim(),
      dateOfBirth: _dobCtrl.text.trim().isEmpty ? null : DateTime.tryParse(_dobCtrl.text.trim()),
      gender: _selectedGender,
      guardianName: _guardianNameCtrl.text.trim().isEmpty ? null : _guardianNameCtrl.text.trim(),
      guardianPhone: _guardianPhoneCtrl.text.trim().isEmpty ? null : _guardianPhoneCtrl.text.trim(),
      addressStreet: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      isActive: widget.student?.isActive ?? true,
    );

    try {
      await provider.addOrUpdateStudent(student);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.student == null ? 'Student added successfully' : 'Student updated'),
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
    final isSaving = context.watch<StudentProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add New Student' : 'Edit Student', style: TextStyle(fontSize: 20.sp)),
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
                    backgroundColor: AppColors.surfaceContainerHigh,
                    backgroundImage: widget.student?.avatarUrl != null 
                        ? NetworkImage(widget.student!.avatarUrl!) 
                        : null,
                    child: widget.student?.avatarUrl == null 
                        ? Icon(Icons.person, size: 50.w, color: AppColors.outline)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20.w),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            
            Text('Personal Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedClassId,
                    decoration: const InputDecoration(labelText: 'Class *', prefixIcon: Icon(Icons.class_outlined)),
                    items: widget.classes.map((c) {
                      return DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text('${c['name']}-${c['section']}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedClassId = val),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _rollNumberCtrl,
                    decoration: const InputDecoration(labelText: 'Roll No', prefixIcon: Icon(Icons.numbers)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dobCtrl,
                    decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today)),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _dobCtrl.text = date.toIso8601String().split('T').first;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.people_outline)),
                    items: ['Male', 'Female', 'Other'].map((g) {
                      return DropdownMenuItem(value: g, child: Text(g));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGender = val);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            
            Text('Guardian Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _guardianNameCtrl,
              decoration: const InputDecoration(labelText: 'Guardian Name', prefixIcon: Icon(Icons.family_restroom)),
            ),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _guardianPhoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined)),
              maxLines: 2,
            ),
            SizedBox(height: 48.h),
            
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveStudent,
                child: isSaving 
                    ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.student == null ? 'Add Student' : 'Save Changes', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
