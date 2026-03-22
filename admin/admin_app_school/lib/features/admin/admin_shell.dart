import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';

import 'dashboard_screen.dart';
import 'student_management.dart';

import 'fees_screen.dart';
import 'notice_screen.dart';
import 'admin_attendance_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentManagementScreen(),
    const AdminAttendanceScreen(),
    const FeesScreen(),
    const NoticeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surfaceContainerLowest,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurfaceVariant,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_grid_2x2),
                activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_2),
                activeIcon: Icon(CupertinoIcons.person_2_fill),
                label: 'Directory',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.calendar_today),
                activeIcon: Icon(CupertinoIcons.calendar_today),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.money_dollar_circle),
                activeIcon: Icon(CupertinoIcons.money_dollar_circle_fill),
                label: 'Fees',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.bell),
                activeIcon: Icon(CupertinoIcons.bell_fill),
                label: 'Notices',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
