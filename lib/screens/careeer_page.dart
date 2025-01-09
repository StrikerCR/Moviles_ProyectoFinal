import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';
import 'package:http/http.dart' as http;

class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  /// Solicitar permisos de almacenamiento
  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    } else {
      openAppSettings(); // Abre los ajustes si el usuario deniega los permisos
      return false;
    }
  }

  /// Descargar el archivo PDF desde la URL
  Future<void> downloadPdf(BuildContext context, String fileName, String fileUrl) async {
    try {
      // Verificar y solicitar permisos
      if (await requestStoragePermission()) {
        // Crear o verificar la carpeta Documents
        final directory = Directory('/storage/emulated/0/Documents');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Verificar si el archivo ya existe y eliminarlo
        if (await file.exists()) {
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo existente eliminado: $filePath'),
            ),
          );
        }

        // Descargar el archivo desde el enlace proporcionado
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo descargado en: $filePath'),
            ),
          );
        } else {
          throw Exception('Error al descargar el archivo desde $fileUrl');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de almacenamiento denegado.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar el archivo: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String career = ModalRoute.of(context)!.settings.arguments as String;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        title: Text(
          career,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('carreras')
            .where('id', isEqualTo: career) // Buscar por el campo 'id'
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los datos: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Datos no disponibles para esta carrera.'),
            );
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final description = data['description'] ?? 'Descripción no disponible.';
          final mapLink = data['mapLink'] ?? '';
          final objetivo = data['objetivo'] ?? 'Objetivo no disponible.';
          final perfilIngreso = data['perfilIngreso'] ?? 'Perfil de ingreso no disponible.';
          final perfilEgreso = data['perfilEgreso'] ?? 'Perfil de egreso no disponible.';
          final campoLaboral = data['campoLaboral'] ?? 'Campo laboral no disponible.';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrera: $career',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 32),
                Text(
                  'Objetivo:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(objetivo, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                const SizedBox(height: 16),
                Text(
                  'Perfil de Ingreso:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(perfilIngreso, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                const SizedBox(height: 16),
                Text(
                  'Perfil de Egreso:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(perfilEgreso, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                const SizedBox(height: 16),
                Text(
                  'Campo Laboral:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(campoLaboral, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (mapLink.isNotEmpty) {
                        await downloadPdf(context, 'MapaCurricular$career.pdf', mapLink);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mapa curricular no disponible.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.currentTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.7,
                        50,
                      ),
                    ),
                    child: const Text(
                      'Descargar Mapa Curricular',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
