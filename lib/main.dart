import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/scanner_viewmodel.dart';
import 'views/scanner_view.dart';

// Constantes de tema podem ser movidas para um arquivo separado (ex: theme.dart)
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
    // O ChangeNotifierProvider é colocado aqui para que o ViewModel
    // esteja disponível para a ScannerView e suas filhas.
    return ChangeNotifierProvider(
      create: (context) => ScannerViewModel(),
      child: MaterialApp(
        title: 'ESP32 BLE Sensores',
        theme: lightTheme,
        home: const MainMenuPage(),
      ),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Principal')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _MenuItem(
            title: 'Scanner BLE',
            subtitle: 'Encontrar e conectar a dispositivos',
            icon: Icons.bluetooth_searching,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerView()),
              );
            },
          ),
          // Adicione outros itens de menu aqui se precisar
        ],
      ),
    );
  }
}

// Widget auxiliar para os itens do menu
class _MenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }
}
