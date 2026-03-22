import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const JikgamApp());
}

class JikgamApp extends StatelessWidget {
  const JikgamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '직감',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAF8),
          foregroundColor: Color(0xFF1C1917),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: Color(0xFF1C1917),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
