/*
 * Título: Ponto de Entrada Principal da Aplicação
 * Descrição: Inicia a aplicação e define a tela de Login como rota inicial.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/login_view.dart';
import 'views/scanner_view.dart'; // Mantenha os imports que podem ser necessários
import 'viewmodels/scanner_viewmodel.dart'; // Mantenha os imports que podem ser necessários

// O tema pode ser mantido aqui ou movido para um arquivo separado
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Colors.blue.shade700,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  cardColor: Colors.white,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black54),
    headlineMedium: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(color: Colors.black87),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue.shade700,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    // Estilo para os campos de texto
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  ).copyWith(secondary: Colors.blueAccent),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos um MultiProvider para gerenciar os ViewModels de diferentes telas
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        // Adicione outros providers de ViewModel aqui se necessário
      ],
      child: MaterialApp(
        title: 'ESP32 Sensor App',
        theme: lightTheme,
        // A tela inicial agora é a LoginView
        home: const LoginView(),
      ),
    );
  }
}
