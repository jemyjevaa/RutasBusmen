import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:geovoy_app/viewModel/login/UserViewModel.dart';
import 'package:geovoy_app/viewmodels/route_viewmodel.dart';
import 'package:geovoy_app/views/maps_view.dart';
import 'package:provider/provider.dart';
import 'services/UserSession.dart';
import 'views/login_screen.dart';
import 'views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Asegurar que las capturas de pantalla estén habilitadas por defecto al iniciar
  try {
    await ScreenProtector.preventScreenshotOff();
  } catch (e) {
    print("Error inicializando ScreenProtector: $e");
  }

  final session = UserSession();
  await session.init();

  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final UserSession session;
  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (context) => RouteViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Rutas Busmen',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        ),
        home: SplashScreen(
          child: session.isLogin ? const MapsView() : const LoginScreen(),
        ),
      ),
    );
  }
}
