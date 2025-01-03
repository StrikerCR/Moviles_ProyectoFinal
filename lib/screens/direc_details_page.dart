import 'package:flutter/material.dart';

class DirecDetailsPage extends StatelessWidget {
  final Map<String, dynamic> directivo;

  DirecDetailsPage({required this.directivo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Directivo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              directivo['nombre_dir'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Departamento: ${directivo['depto_direc']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 8),
                Text(directivo['correo_direc']),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 8),
                Text(directivo['telefono_direc']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
