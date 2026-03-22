import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notice_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/filter_chips.dart';
import 'add_notice.dart';

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoticeScreen()),
          );
        },
        icon: Icon(Icons.campaign_rounded, size: 24.w),
        label: Text('Send Notice', style: TextStyle(fontSize: 14.sp)),
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
}

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : "";
  }
}
