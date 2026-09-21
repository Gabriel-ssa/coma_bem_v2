import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/splash_screen.dart'; // Importa a tela inicial do seu app

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessário para o sqflite funcionar no Windows/Linux/macOS
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de DEBUG
      title: 'Coma Bem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF055442)),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Abre a Splash Screen primeiro
    );
  }
}