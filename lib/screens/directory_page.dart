import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DirectoryPage extends StatefulWidget {
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  List<Map<String, dynamic>> directivos = [];

  @override
  void initState() {
    super.initState();
    fetchDirectivos();
  }

  Future<void> fetchDirectivos() async {
    try {
      // Referencia a la colección "directivos" en Firebase
      final querySnapshot =
          await FirebaseFirestore.instance.collection('directivos').get();

      // Convierte los documentos en una lista de mapas
      final List<Map<String, dynamic>> fetchedDirectivos = querySnapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      setState(() {
        directivos = fetchedDirectivos;
      });
    } catch (e) {
      print("Error al obtener los directivos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el directorio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Directorio')),
      body: directivos.isEmpty
          ? Center(child: CircularProgressIndicator()) // Muestra un cargando mientras se obtienen los datos
          : ListView.builder(
              itemCount: directivos.length,
              itemBuilder: (context, index) {
                final directivo = directivos[index];
                return ListTile(
                  title: Text(directivo['nombre_dir']),
                  subtitle: Text(directivo['depto_direc']),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/teacherDetails',
                      arguments: directivo,
                    );
                  },
                );
              },
            ),
    );
  }
}
