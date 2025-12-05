import 'package:flutter/material.dart';
import 'package:geovoy_app/viewModel/login/UserViewModel.dart';
import 'package:geovoy_app/views/maps_view.dart';
import 'package:provider/provider.dart';
import 'services/UserSession.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = UserSession();
  await session.init();

  runApp(MyApp(session: session));
}
class MyApp extends StatelessWidget {
  final UserSession session;
  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {

    var mainScreen = session.isLogin ? MapsView() : LoginScreen();

    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rutas Busmen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        ),
        home: mainScreen,
      ),
    );
  }
}