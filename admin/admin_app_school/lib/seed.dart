import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('--- Supabase User Seeding ---');
  
  final supabase = SupabaseClient(
    'https://ygtxsykpihqbzzgbqyew.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndHhzeWtwaWhxYnp6Z2JxeWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzg2OTksImV4cCI6MjA4OTcxNDY5OX0.htrQPKADyuUE5azY-WZkY7Aii2NBdsBs_5_jakHOMzI',
  );

  final users = [
    {'email': 'admin@school.com', 'password': 'Admin@123', 'role': 'admin', 'name': 'System Admin'},
    {'email': 'teacher@school.com', 'password': 'Teacher@123', 'role': 'teacher', 'name': 'John Smith'},
    {'email': 'student@school.com', 'password': 'Student@123', 'role': 'student', 'name': 'Jane Student'},
  ];

  for (final user in users) {
    try {
      print('Registering ${user['email']}...');
      final response = await supabase.auth.signUp(
        email: user['email'],
        password: user['password']!,
        data: {'full_name': user['name']},
      );

      if (response.user != null) {
        print('User ${user['email']} registered successfully. ID: ${response.user!.id}');
        
        // Ensure public profile exists with correct role
        await supabase.from('users').upsert({
          'id': response.user!.id,
          'email': user['email'],
          'full_name': user['name'],
          'role': user['role'],
        });
        print('Profile for ${user['role']} created.');
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        print('User ${user['email']} already exists.');
        // Optionally update the role if needed
      } else {
        print('Error registering ${user['email']}: $e');
      }
    }
  }

  print('--- Seeding Complete ---');
}
