import 'package:flutter/material.dart';
import 'package:proyecto_final_fbdp_crr/baseDatos/database_connection.dart';

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
    final db = await DBConnection().database;
    final result = await db.query('directivos');
    setState(() {
      directivos = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Directorio')),
      body: ListView.builder(
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
