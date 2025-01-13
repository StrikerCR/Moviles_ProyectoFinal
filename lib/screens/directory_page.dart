import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class DirectoryPage extends StatefulWidget {
  @override
  _DirectoryPageState createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  List<Map<String, dynamic>> directivos = [];
  List<Map<String, dynamic>> filteredDirectivos = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDirectivos();
    searchController.addListener(() {
      filterDirectivos();
    });
  }

  Future<void> fetchDirectivos() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('directivos').get();

      final List<Map<String, dynamic>> fetchedDirectivos = querySnapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      setState(() {
        directivos = fetchedDirectivos;
        filteredDirectivos = fetchedDirectivos;
      });
    } catch (e) {
      print("Error al obtener los directivos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el directorio: $e')),
      );
    }
  }

  void filterDirectivos() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDirectivos = directivos
          .where((directivo) =>
              directivo['nombre_dir'].toLowerCase().contains(query) ||
              directivo['depto_direc'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        toolbarHeight: 48.0, // Altura mínima del AppBar
        title: Text(
          'Directorio',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeProvider.currentTheme.primaryColor,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar directivo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: filteredDirectivos.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron resultados.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredDirectivos.length,
                      itemBuilder: (context, index) {
                        final directivo = filteredDirectivos[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: themeProvider.currentTheme.primaryColor,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12.0),
                              title: Text(
                                directivo['nombre_dir'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.currentTheme.primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                directivo['depto_direc'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/direcDetails',
                                  arguments: directivo,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
