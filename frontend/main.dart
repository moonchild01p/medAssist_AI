import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MedAssistApp());
}

class MedAssistApp extends StatelessWidget {
  const MedAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAssist AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E8C),
          primary: const Color(0xFFE91E8C),
          secondary: const Color(0xFF9C27B0),
          surface: const Color(0xFFFAFAFA),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}