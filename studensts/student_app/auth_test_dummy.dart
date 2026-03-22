import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://ygtxsykpihqbzzgbqyew.supabase.co/auth/v1/token?grant_type=password');
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndHhzeWtwaWhxYnp6Z2JxeWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzg2OTksImV4cCI6MjA4OTcxNDY5OX0.htrQPKADyuUE5azY-WZkY7Aii2NBdsBs_5_jakHOMzI';
  
  final client = HttpClient();
  
  Future<void> testLogin(String email, String password) async {
    var request = await client.postUrl(url);
    request.headers.set('apikey', anonKey);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({'email': email, 'password': password}));
    var response = await request.close();
    print('$email: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('${await response.transform(utf8.decoder).join()}');
    }
  }

  await testLogin('student@school.com', 'Student@123');
  await testLogin('dummystudent@school.com', 'Student@123');
  
  client.close();
}
