import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://ygtxsy');
  final anonKey = 'eyJhbGciOiJIUHOMzI';
  
  final client = HttpClient();
  
  final accounts = [
    {'email': 'student@school.com', 'password': 'Student@123'},
    {'email': 'admin@school.com', 'password': 'Admin@123'},
    {'email': 'teacher@school.com', 'password': 'Teacher@123'},
  ];

  for (var acc in accounts) {
    try {
      final request = await client.postUrl(url);
      request.headers.set('apikey', anonKey);
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(acc));
      
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      print('${acc['email']} status: ${response.statusCode}');
      print('Response: $body');
    } catch (e) {
      print('Error recreating ${acc['email']}: $e');
    }
  }
  client.close();
}
