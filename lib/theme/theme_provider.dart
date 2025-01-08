import 'package:flutter/material.dart';

// Mapa de temas
final Map<String, ThemeData> themes = {
  'Azul': ThemeData(
    primaryColor: Color.fromARGB(255, 0, 93, 139),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Color.fromARGB(255, 0, 93, 139),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 0, 93, 139),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 93, 139)),
      ),
      border: OutlineInputBorder(),
    ),
  ),
  'Morado': ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.deepPurple,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      border: OutlineInputBorder(),
    ),
  ),
  'Guinda': ThemeData(
    primaryColor: Color.fromARGB(255, 128, 0, 64),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Color.fromARGB(255, 128, 0, 64),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 128, 0, 64),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 128, 0, 64)),
      ),
      border: OutlineInputBorder(),
    ),
  ),
  'Naranja': ThemeData(
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.orange,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
      ),
      border: OutlineInputBorder(),
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
