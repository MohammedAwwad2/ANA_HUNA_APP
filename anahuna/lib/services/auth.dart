import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _baseUrl =
      'https://0009-2a01-9700-9412-ad00-30a1-101f-cee7-73a5.ngrok-free.app/api/v1';
  static const String _tokenKey = 'auth_token';

  bool isAuthenticated = false;

  Future<void> saveAuthToken(String token) async {
    if (token.isEmpty) {
      throw Exception('Token cannot be empty');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    isAuthenticated = true;
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    isAuthenticated = token != null;
    return token;
  }

  Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getAuthToken();
    
    if (token == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );
      
      if (response.statusCode == 200 || response.statusCode == 401) {
        await prefs.remove(_tokenKey);
        await prefs.clear();
        isAuthenticated = false;
      } else {
        throw Exception('Logout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      await prefs.remove(_tokenKey);
      await prefs.clear();
      isAuthenticated = false;
      throw Exception('Failed to logout: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!responseBody.containsKey('token')) {
          throw Exception('Token not found in response');
        }

        final token = responseBody['token'];
        await saveAuthToken(token);

        return {
          'success': true,
          'message': "تم تسجيل الدخول بنجاح!",
          'data': responseBody
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Login failed',
          'data': responseBody
        };
      }
    } 
    catch (e) {
      return {
        'success': false,
        'message': 'خطأ في البريد الكتروني او كلمة السر',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': '$firstName $lastName',
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!responseBody.containsKey('token')) {
          throw Exception('Token not found in response');
        }

        final token = responseBody['token'];
        await saveAuthToken(token);

        return {
          'success': true,
          'message': "تم إنشاء الحساب بنجاح!",
          'data': responseBody
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Registration failed',
          'data': responseBody
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'عذراً، حدث خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        'data': null
      };
    }
  }
}
