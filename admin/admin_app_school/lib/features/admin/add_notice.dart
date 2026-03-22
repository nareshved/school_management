import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notice_model.dart';
import '../../providers/notice_provider.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  
  String _selectedCategory = 'General';
  String _targetAudience = 'All';
  bool _isPinned = false;

  final _categories = ['General', 'Academic', 'Event', 'Urgent'];
  final _audiences = ['All', 'Teachers', 'Students', 'Parents'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotice() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<NoticeProvider>();
    final notice = NoticeModel(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      category: _selectedCategory,
      targetType: _targetAudience.toLowerCase(),
      isPinned: _isPinned,
      createdBy: 'admin_123', // In a real app, get from auth provider
    );

    try {
      await provider.addNotice(notice);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice sent successfully'), backgroundColor: AppColors.success),
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
    final isSaving = context.watch<NoticeProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Create Notice', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Notice Title *', prefixIcon: Icon(Icons.title)),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetAudience,
                    decoration: const InputDecoration(labelText: 'Target Audience', prefixIcon: Icon(Icons.people_outline)),
                    items: _audiences.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _targetAudience = val);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Notice Content *',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.subject),
                ),
              ),
              maxLines: 5,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: const Text('Pin to Top'),
              subtitle: const Text('Keep this notice at the top of the board'),
              value: _isPinned,
              activeThumbColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              tileColor: AppColors.surfaceContainerLowest,
              onChanged: (val) => setState(() => _isPinned = val),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              height: 56.h,
              child: ElevatedButton(
                onPressed: isSaving ? null : _sendNotice,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: isSaving
                    ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Publish Notice', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
