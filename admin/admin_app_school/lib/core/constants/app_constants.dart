class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://ygtxsykpihqbzzgbqyew.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndHhzeWtwaWhxYnp6Z2JxeWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzg2OTksImV4cCI6MjA4OTcxNDY5OX0.htrQPKADyuUE5azY-WZkY7Aii2NBdsBs_5_jakHOMzI';

  static const String appName = 'Smart School';
  static const String tagline = 'MANAGE. EDUCATE. EXCEL.';
  static const String poweredBy = 'POWERED BY SCHOLASTIC CURATOR';

  static const String academicYear = '2024-2025';

  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  static const List<String> genderOptions = ['Male', 'Female', 'Other'];

  static const List<String> feeTypes = [
    'Tuition',
    'Admission',
    'Examination',
    'Library',
    'Transport',
    'Laboratory',
    'Sports',
    'Other',
  ];

  static const List<String> noticeCategories = [
    'important',
    'academic',
    'events',
    'general',
  ];
}
