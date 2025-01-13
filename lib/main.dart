import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final_fbdp_crr/baseDatos/insertar_datos.dart';
import 'package:proyecto_final_fbdp_crr/firebase_options.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    //insertDatos();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('alumnos')
            .doc(currentUser!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data();
          });
        }
      } catch (e) {
        debugPrint('Error al cargar datos del usuario: $e');
      }
    }
  }

  void logout(BuildContext context) async {

    await FirebaseAuth.instance.signOut();
    setState(() {
      currentUser = null;
      userData = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ThemeProvider>(context, listen: false).changeTheme('Azul');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onLoginSuccess: (user) async {
                setState(() {
                  currentUser = FirebaseAuth.instance.currentUser;
                });
                await _loadUserData();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCOMBROSpy',
      theme: themeProvider.currentTheme,
      initialRoute: currentUser != null ? '/' : '/login',
      routes: {
        '/': (context) => HomePage(
              isAuthenticated: currentUser != null,
              userData: userData,
              onLogout: () => logout(context),
            ),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(
              onLoginSuccess: (user) async {
                setState(() {
                  currentUser = FirebaseAuth.instance.currentUser;
                });
                await _loadUserData();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
        '/account': (context) {
          if (userData == null) {
            return LoginPage(
              onLoginSuccess: (user) async {
                setState(() {
                  currentUser = FirebaseAuth.instance.currentUser;
                });
                await _loadUserData();
                Navigator.pushReplacementNamed(context, '/');
              },
            );
          } else {
            return AccountPage(
              userData: userData!,
              onLogout: () => logout(context),
            );
          }
        },
        '/directory': (context) => DirectoryPage(),
        '/map': (context) => MapPage(),
        '/career': (context) => CareerPage(),
        '/direcDetails': (context) {
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
