import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://ygtxsykpihqbzzgbqyew.supabase.co/auth/v1/token?grant_type=password');
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndHhzeWtwaWhxYnp6Z2JxeWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzg2OTksImV4cCI6MjA4OTcxNDY5OX0.htrQPKADyuUE5azY-WZkY7Aii2NBdsBs_5_jakHOMzI';
  
  final client = HttpClient();
  try {
    var request = await client.postUrl(url);
    request.headers.set('apikey', anonKey);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({'email': 'student@school.com', 'password': 'Student@123'}));
    var response = await request.close();
    print('Student Status: ${response.statusCode}');
    print('Student Response: ${await response.transform(utf8.decoder).join()}');

    var request2 = await client.postUrl(url);
    request2.headers.set('apikey', anonKey);
    request2.headers.set('Content-Type', 'application/json');
    request2.write(jsonEncode({'email': 'admin@school.com', 'password': 'Admin@123'}));
    var response2 = await request2.close();
    print('Admin Status: ${response2.statusCode}');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
