import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/screens/account_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/careeer_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/directory_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/home_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/login_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/map_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/professor_details_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/professors_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/register_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/direc_details_page.dart';
import 'package:proyecto_final_fbdp_crr/screens/settings_page.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false; // Estado de autenticación
  Map<String, dynamic>? userData; // Datos del usuario

  void logout() {
    setState(() {
      isAuthenticated = false;
      userData = null;
    });
    // Restablecer el tema al cerrar sesión
    Provider.of<ThemeProvider>(context, listen: false).changeTheme('Azul');
  }

  void loginSuccess(Map<String, dynamic> user) {
    setState(() {
      isAuthenticated = true;
      userData = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCOMBROSpy',
      theme: themeProvider.currentTheme, // Conecta el tema dinámico
      initialRoute: isAuthenticated ? '/' : '/login',
      routes: {
        '/': (context) => HomePage(
              isAuthenticated: isAuthenticated,
              userData: userData,
              onLogout: logout,
            ),
        '/login': (context) => LoginPage(
              onLoginSuccess: loginSuccess,
            ),
        '/register': (context) => RegisterPage(),
        '/account': (context) {
          if (userData == null) {
            return LoginPage(
              onLoginSuccess: loginSuccess,
            );
          } else {
            return AccountPage(
              userData: userData!,
              onLogout: logout,
            );
          }
        },
        '/directory': (context) => DirectoryPage(),
        '/map': (context) => MapPage(),
        '/career': (context) => CareerPage(),
        '/teacherDetails': (context) {
          final directivo = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (directivo == null) {
            return Scaffold(
              body: Center(
                child: Text('Error: Datos del directivo no disponibles.'),
              ),
            );
          }
          return DirecDetailsPage(directivo: directivo);
        },
        '/professors': (context) {
          if (userData == null) {
            return Scaffold(
              body: Center(
                child: Text('Error: No hay datos del usuario.'),
              ),
            );
          }
          return ProfessorsPage(userData: userData!);
        },
        '/professorDetails': (context) => ProfessorDetailsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
