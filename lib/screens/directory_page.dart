import 'package:flutter/material.dart';

class DirectoryPage extends StatelessWidget {
  const DirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directorio'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Juan Pérez'),
            subtitle: Text('Profesor de Programación'),
            onTap: () {
              Navigator.pushNamed(context, '/teacherDetails');
            },
          ),
          ListTile(
            title: Text('Ana López'),
            subtitle: Text('Coordinadora de IA'),
            onTap: () {
              Navigator.pushNamed(context, '/teacherDetails');
            },
          ),
        ],
      ),
    );
  }
}