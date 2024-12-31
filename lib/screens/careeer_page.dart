import 'package:flutter/material.dart';

class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String career = ModalRoute.of(context)!.settings.arguments as String;

    String description;
    String mapLink;

    switch (career) {
      case 'ISC':
        description = 'Ingeniería en Sistemas Computacionales se enfoca en el desarrollo de software, redes y soluciones tecnológicas avanzadas.';
        mapLink = 'curriculum_isc.pdf';
        break;
      case 'IA':
        description = 'Inteligencia Artificial estudia y desarrolla sistemas que simulan inteligencia humana en máquinas.';
        mapLink = 'curriculum_ia.pdf';
        break;
      case 'LCD':
        description = 'La Licenciatura en Ciencias de Datos se centra en el análisis y manejo de datos para la toma de decisiones informadas.';
        mapLink = 'curriculum_lcd.pdf';
        break;
      default:
        description = 'Información no disponible para esta carrera.';
        mapLink = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(career),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carrera: $career',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Lógica para descargar el mapa curricular
                print('Descargando $mapLink');
              },
              child: Text('Descargar Mapa Curricular $career'),
            ),
          ],
        ),
      ),
    );
  }
}