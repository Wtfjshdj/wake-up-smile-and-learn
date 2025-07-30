import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/local_storage_service.dart';
import 'services/alarm_service.dart';
import 'services/music_service.dart';
import 'package:receive_intent/receive_intent.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await AlarmService().init();
  await MusicService().initialize();

  runApp(const WakeUpSmileAndLearnApp());
}

class WakeUpSmileAndLearnApp extends StatelessWidget {
  const WakeUpSmileAndLearnApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Wake Up, Smile and Learn',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
