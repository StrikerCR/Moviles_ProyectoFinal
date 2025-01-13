import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

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

  /// Descargar el archivo PDF directamente desde Firebase Storage
  Future<void> downloadFileFromFirebase(BuildContext context, String storagePath, String localFileName) async {
    try {
      // Solicitar permisos de almacenamiento
      if (await requestStoragePermission()) {
        // Obtener el directorio de almacenamiento del dispositivo
        final directory = Directory('/storage/emulated/0/Documents');
        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo acceder al directorio de almacenamiento.'),
            ),
          );
          return;
        }

        // Construir la ruta completa del archivo local
        final String localPath = '${directory.path}/$localFileName';

        // Crear una referencia al archivo en Firebase Storage
        final Reference firebaseStorageRef = FirebaseStorage.instance.ref(storagePath);

        // Descargar el archivo y guardarlo localmente
        final File file = File(localPath);
        await firebaseStorageRef.writeToFile(file);

        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo descargado en: $localPath'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permisos de almacenamiento denegados.'),
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
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          final mapLink = data['mapLink'] ?? ''; // Ruta en Firebase Storage
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
                        await downloadFileFromFirebase(context, mapLink, 'MapaCurricular${career}2020.pdf');
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
