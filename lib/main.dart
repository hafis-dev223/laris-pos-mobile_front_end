import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const LarisApp());
}

class LarisApp extends StatelessWidget {
  const LarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laris POS',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}