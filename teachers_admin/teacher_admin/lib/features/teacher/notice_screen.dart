import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notice_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/filter_chips.dart';
import '../../models/notice_model.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Academic', 'Event', 'Urgent'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoticeProvider>();

    final filteredNotices = provider.notices.where((n) {
      if (_selectedCategory == 'All') return true;
      return n.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Notice Board', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surfaceContainerLowest,
            padding: EdgeInsets.only(bottom: 16.h),
            child: FilterChips(
              options: _categories,
              selectedOption: _selectedCategory,
              onSelected: (val) => setState(() => _selectedCategory = val),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotices.isEmpty
                    ? Center(
                        child: Text(
                          'No notices found',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16.sp),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                        itemCount: filteredNotices.length,
                        separatorBuilder: (context, index) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) => _buildNoticeCard(filteredNotices[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoticeDialog(context),
        icon: Icon(Icons.campaign_rounded, size: 24.w),
        label: Text('Send Notice', style: TextStyle(fontSize: 14.sp)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildNoticeCard(dynamic notice) {
    final isPinned = notice.isPinned ?? false;

    Color categoryColor;
    switch (notice.category.toLowerCase()) {
      case 'academic': categoryColor = AppColors.primary; break;
      case 'event': categoryColor = AppColors.secondary; break;
      case 'urgent': categoryColor = AppColors.error; break;
      default: categoryColor = AppColors.tertiary;
    }

    return CustomCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  notice.category,
                  style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              ),
              if (isPinned)
                Icon(Icons.push_pin_rounded, color: AppColors.error, size: 20.w),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            notice.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            notice.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant, height: 1.5, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16.w, color: AppColors.onSurfaceVariant),
                  SizedBox(width: 4.w),
                  Text(
                    'To: ${notice.targetAudience.capitalize()}',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(notice.createdAt ?? DateTime.now()),
                style: TextStyle(color: AppColors.outline, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'General';
    String audience = 'student'; // Teachers mostly send notices to students
    
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
                  Text('Send Class Notice', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: ['General', 'Academic', 'Event', 'Urgent'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                        
                        final sm = ScaffoldMessenger.of(context);
                        try {
                          Navigator.pop(context);
                          await context.read<NoticeProvider>().addNotice(
                            NoticeModel(
                              title: titleCtrl.text,
                              content: contentCtrl.text,
                              category: category,
                              targetType: audience,
                            ),
                          );
                          sm.showSnackBar(
                            const SnackBar(content: Text('Notice sent!'), backgroundColor: AppColors.success),
                          );
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
                      child: Text('Send Notice', style: TextStyle(fontSize: 16.sp)),
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

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : "";
  }
}
