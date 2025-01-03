import 'package:flutter/material.dart';

class ProfessorsPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Datos del usuario autenticado

  ProfessorsPage({required this.userData});

  @override
  _ProfessorsPageState createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  final List<Map<String, String>> professors = [
    {
      'name': 'Nombre Profesor 1',
      'department': 'Depto. Académico',
      'email': 'prof1@escom.mx',
      'location': 'Cubículo A',
      'schedule': 'Lunes a Viernes, 9:00 - 14:00',
    },
    {
      'name': 'Nombre Profesor 2',
      'department': 'Depto. Académico',
      'email': 'prof2@escom.mx',
      'location': 'Cubículo B',
      'schedule': 'Lunes a Viernes, 10:00 - 15:00',
    },
    // Agrega más profesores aquí
  ];

  late List<Map<String, String>> filteredProfessors;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProfessors = professors;

    searchController.addListener(() {
      filterProfessors();
    });
  }

  void filterProfessors() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProfessors = professors
          .where((professor) =>
              professor['name']!.toLowerCase().contains(query) ||
              professor['department']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profesores'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hola ${widget.userData['nombre_es']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar profesor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProfessors.length,
              itemBuilder: (context, index) {
                final professor = filteredProfessors[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(professor['name']![0]), // Primera letra del nombre
                  ),
                  title: Text(professor['name']!),
                  subtitle: Text(professor['department']!),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/professorDetails',
                      arguments: professor,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
