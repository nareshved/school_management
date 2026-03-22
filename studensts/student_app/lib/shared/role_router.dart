import '../config/app_config.dart';

String getDashboardRoute(String role) {
  switch (role) {
    case "admin":
      return AppConfig.dashboardRoutes[AppRole.admin]!;
    case "teacher":
      return AppConfig.dashboardRoutes[AppRole.teacher]!;
    case "student":
      return AppConfig.dashboardRoutes[AppRole.student]!;
    default:
      return "/login";
  }
}
