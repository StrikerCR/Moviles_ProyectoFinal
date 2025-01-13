import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class DirecDetailsPage extends StatelessWidget {
  final Map<String, dynamic> directivo;

  DirecDetailsPage({required this.directivo});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Directivo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeProvider.currentTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Espacio para la imagen en un círculo
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: themeProvider.currentTheme.colorScheme.secondary,
                  backgroundImage: directivo['imagen_url'] != null
                      ? NetworkImage(directivo['imagen_url'])
                      : null,
                  child: directivo['imagen_url'] == null
                      ? Icon(
                          Icons.person,
                          size: 80,
                          color: themeProvider.currentTheme.primaryColor,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              // Nombre del directivo
              Text(
                directivo['nombre_dir'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              // Encabezado y Departamento
              Text(
                'Departamento:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                directivo['depto_direc'],
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              // Correo electrónico
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      directivo['correo_direc'] ?? 'No disponible',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Teléfono
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    directivo['telefono_direc'] ?? 'No disponible',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
