import 'package:flutter/material.dart';
import 'package:anahuna/pages/onboarding_screen.dart';
import 'package:anahuna/pages/home_screen.dart';
import 'package:anahuna/services/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await AuthService().getAuthToken();
    if (mounted) {
      setState(() {
        _isAuthenticated = AuthService().isAuthenticated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isAuthenticated ? const HomeScreen() : const ChoosingScreen(),
    );
  }
}
