import 'package:flutter/material.dart';
import 'package:proyecto_final_fbdp_crr/careeer_page.dart';
import 'package:proyecto_final_fbdp_crr/directory_page.dart';
import 'package:proyecto_final_fbdp_crr/home_page.dart';
import 'package:proyecto_final_fbdp_crr/login_page.dart';
import 'package:proyecto_final_fbdp_crr/map_page.dart';
import 'package:proyecto_final_fbdp_crr/register_page.dart';
import 'package:proyecto_final_fbdp_crr/teacher_details_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCOM Spy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/directory': (context) => DirectoryPage(),
        '/map': (context) => MapPage(),
        '/career': (context) => CareerPage(),
        '/teacherDetails': (context) => TeacherDetailsPage(),
      },
    );
  }
}