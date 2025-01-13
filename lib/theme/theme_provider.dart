import 'package:flutter/material.dart';

// Mapa de temas con colores secundarios más claros
final Map<String, ThemeData> themes = {
  'Azul': ThemeData(
    primaryColor: const Color.fromARGB(255, 0, 93, 139),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 0, 93, 139),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 93, 139),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 93, 139)),
      ),
      border: OutlineInputBorder(),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 173, 216, 230), // Azul claro
    ),
  ),
  'Morado': ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.deepPurple,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      border: OutlineInputBorder(),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 216, 191, 216), // Lila claro
    ),
  ),
  'Guinda': ThemeData(
    primaryColor: const Color.fromARGB(255, 128, 0, 64),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 128, 0, 64),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 128, 0, 64),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 128, 0, 64)),
      ),
      border: OutlineInputBorder(),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 255, 182, 193), // Rosa claro
    ),
  ),
  'Naranja': ThemeData(
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.orange,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
      ),
      border: OutlineInputBorder(),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 255, 228, 181), // Melón claro
    ),
  ),
};

// Clase para gestionar el cambio de tema
class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = themes['Azul']!;

  ThemeData get currentTheme => _currentTheme;

  void changeTheme(String themeName) {
    if (themes.containsKey(themeName)) {
      _currentTheme = themes[themeName]!;
      notifyListeners(); // Asegura que todos los oyentes se actualicen
    } else {
      print('Tema "$themeName" no encontrado en el mapa de temas.');
    }
  }
}
