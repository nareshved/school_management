import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/teacher_provider.dart';
import '../../models/teacher_model.dart';
import '../../widgets/custom_card.dart';
import 'add_edit_teacher.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState
    extends State<TeacherManagementScreen> {
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
      return t.fullName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          t.displaySubject
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Teachers',
            style:
                TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, size: 24.w),
            onPressed: () => _showSearch(context, provider),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(provider, context),
                ),
                if (_searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSearchBar(),
                  ),
                filteredTeachers.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmpty(),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: EdgeInsets.fromLTRB(
                                20.w, i == 0 ? 8.h : 0, 20.w, 16.h),
                            child: _buildTeacherCard(
                                filteredTeachers[i], provider),
                          ),
                          childCount: filteredTeachers.length,
                        ),
                      ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(context, provider, null),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add_alt_1_rounded, size: 22.w),
        label: Text('Add Teacher',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildHeader(TeacherProvider provider, BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FACULTY MANAGEMENT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${provider.teachers.length} Teachers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Overseeing academic excellence and classroom engagement.',
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAddEdit(context, provider, null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding:
                    EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: Icon(Icons.person_add_alt_1_rounded, size: 20.w),
              label: Text('Add New Faculty',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: TextField(
        autofocus: true,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search teachers or subjects...',
          prefixIcon: Icon(Icons.search_rounded, size: 20.w),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 20.w),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher, TeacherProvider provider) {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.secondaryContainer,
                backgroundImage: teacher.avatarUrl != null
                    ? NetworkImage(teacher.avatarUrl!)
                    : null,
                child: teacher.avatarUrl == null
                    ? Text(
                        teacher.fullName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        if (teacher.primaryClass != 'Unassigned')
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              teacher.primaryClass,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      teacher.displaySubject,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    size: 22.w, color: AppColors.onSurfaceVariant),
                onSelected: (value) async {
                  if (value == 'edit') {
                    _openAddEdit(context, provider, teacher);
                  } else if (value == 'delete') {
                    _confirmDelete(context, provider, teacher);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined,
                          size: 18.w, color: AppColors.primary),
                      SizedBox(width: 8.w),
                      Text('Edit Info',
                          style: TextStyle(fontSize: 14.sp)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18.w, color: AppColors.error),
                      SizedBox(width: 8.w),
                      Text('Remove',
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),
          // Stats row
          Row(
            children: [
              _buildStat('STUDENTS', '${teacher.studentCount}',
                  AppColors.onSurfaceVariant),
              _buildDivider(),
              _buildStat('ATTENDANCE',
                  '${teacher.attendancePercent.toStringAsFixed(0)}%',
                  AppColors.success),
              _buildDivider(),
              _buildStat('RATING',
                  teacher.rating > 0
                      ? '${teacher.rating.toStringAsFixed(1)} ★'
                      : '—',
                  AppColors.tertiary),
            ],
          ),

          // Assigned classes chips
          if (teacher.assignedClasses.isNotEmpty) ...[
            SizedBox(height: 12.h),
            const Divider(),
            SizedBox(height: 8.h),
            Text('Assigned Classes',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: teacher.assignedClasses
                  .map((c) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: AppColors.outlineVariant),
                        ),
                        child: Text(c,
                            style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface)),
                      ))
                  .toList(),
            ),
          ],

          SizedBox(height: 14.h),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openAddEdit(context, provider, teacher),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text('Edit',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text('View Profile',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          SizedBox(height: 4.h),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        height: 32.h,
        width: 1,
        color: AppColors.outlineVariant);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded,
              size: 64.w, color: AppColors.outline),
          SizedBox(height: 16.h),
          Text('No teachers found',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 16.sp)),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, TeacherProvider provider) {
    setState(() => _searchQuery = ' '); // triggers search bar to show
  }

  void _openAddEdit(
      BuildContext context, TeacherProvider provider, TeacherModel? teacher) {
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

  Future<void> _confirmDelete(
      BuildContext context, TeacherProvider provider, TeacherModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Teacher', style: TextStyle(fontSize: 18.sp)),
        content: Text(
            'Are you sure you want to remove ${teacher.fullName} from the faculty?',
            style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: TextStyle(
                    color: AppColors.error, fontSize: 14.sp)),
          ),
        ],
      ),
    );
    if (confirm == true && teacher.id != null) {
      try {
        await provider.deleteTeacher(teacher.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teacher removed successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}
