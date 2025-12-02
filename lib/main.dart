import 'package:flutter/material.dart';
import 'views/login_screen.dart';

import 'utils/app_strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, language, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rutas Busmen',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}