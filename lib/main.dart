import 'package:flutter/material.dart';
import 'package:geovoy_app/viewModel/login/UserViewModel.dart';
import 'package:provider/provider.dart';
import 'services/UserSession.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = UserSession();
  await session.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rutas Busmen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
