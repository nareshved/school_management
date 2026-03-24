import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://ygtxsykpihqbzzgbqyew.supabase.co/auth/v1/signup');
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndHhzeWtwaWhxYnp6Z2JxeWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMzg2OTksImV4cCI6MjA4OTcxNDY5OX0.htrQPKADyuUE5azY-WZkY7Aii2NBdsBs_5_jakHOMzI';
  
  final client = HttpClient();
  
  final acc = {'email': 's_student@school.com', 'password': 'School@123'};

  try {
    final request = await client.postUrl(url);
    request.headers.set('apikey', anonKey);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(acc));
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  }
  client.close();
}
