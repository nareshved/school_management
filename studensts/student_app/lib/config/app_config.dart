enum AppRole { admin, teacher, student }

class AppConfig {
  static const bool enableAI = true;
  static const bool enableNotifications = false;

  static const List<AppRole> enabledRoles = [
    AppRole.admin,
    AppRole.teacher,
    AppRole.student,
  ];

  static const String appName = "Smart School App";

  static Map<AppRole, String> dashboardRoutes = {
    AppRole.admin: "/admin_dashboard",
    AppRole.teacher: "/teacher_dashboard",
    AppRole.student: "/student_dashboard",
  };
}
