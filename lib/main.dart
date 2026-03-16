import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('current_user_email');
  runApp(HabitFlowApp(isLoggedIn: userEmail != null));
}

class HabitFlowApp extends StatelessWidget {
  final bool isLoggedIn;
  const HabitFlowApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7C5CFC),
          secondary: const Color(0xFF9D7DFF),
          background: const Color(0xFF080810),
          surface: const Color(0xFF12121E),
        ),
        scaffoldBackgroundColor: const Color(0xFF080810),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}