import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class ProfessorsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfessorsPage({required this.userData});

  @override
  _ProfessorsPageState createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> professors = [];
  List<Map<String, dynamic>> filteredProfessors = [];
  bool isLoading = false;
  String selectedAcademy = "Todas";

  final List<String> academies = [
    "Todas",
    "Academia de Ciencia Básicas",
    "Academia de Ciencias de la Comunicación",
    "Academia de Ciencias Sociales",
    "Academia de Fundamentos de Sistemas Electrónicos",
    "Academia de Ingeniería de Software",
    "Academia de Proyectos Estratégicos y Toma de Decisiones",
    "Academia de Sistemas Digitales",
    "Academia de Sistemas Distribuidos",
    "Academia de Ciencia de Datos",
    "Academia de Inteligencia Artificial",
  ];

  @override
  void initState() {
    super.initState();
    fetchProfessors();
    searchController.addListener(filterProfessors);
  }

  Future<void> fetchProfessors() async {
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('profesores')
          .orderBy('nombre')
          .get();

      final List<Map<String, dynamic>> fetchedProfessors = querySnapshot.docs
          .map((doc) => {
                "id": doc.id, // Mantén el ID del documento
                ...doc.data()
                    as Map<String, dynamic>, // Incluye todos los datos
              })
          .map((professor) => {
                "id": professor["id"], // Incluye el ID
                "nombre":
                    professor["nombre"] ?? "Sin Nombre", // Extrae el nombre
                "academia": professor["academia"] ??
                    "Sin Academia", // Extrae la academia
                "num_empleado": professor["num_empleado"] ??
                    "No asignado", // Incluye num_empleado
              })
          .toList();

      setState(() {
        professors = fetchedProfessors;
        filteredProfessors = fetchedProfessors;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar profesores: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterProfessors() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProfessors = professors
          .where((professor) =>
              (professor['nombre'].toLowerCase().contains(query) ||
                  professor['academia'].toLowerCase().contains(query)) &&
              (selectedAcademy == "Todas" ||
                  professor['academia'] == selectedAcademy))
          .toList();
    });
  }

  void filterByLetter(String letter) {
    setState(() {
      if (letter == "ALL") {
        filteredProfessors = professors;
      } else {
        filteredProfessors = professors
            .where((professor) =>
                professor['nombre'].toUpperCase().startsWith(letter) &&
                (selectedAcademy == "Todas" ||
                    professor['academia'] == selectedAcademy))
            .toList();
      }
    });
  }

  void showFilterModal(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Text(
                "Filtrar por Academia",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: academies.map(
                    (academy) {
                      final isSelected = academy == selectedAcademy;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAcademy = academy;
                            filterProfessors();
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeProvider.currentTheme.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeProvider.currentTheme.primaryColor,
                              width: 2.5, // Grosor aumentado
                            ),
                          ),
                          child: Text(
                            academy,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : themeProvider.currentTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profesores',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_rounded, color: Colors.white),
            onPressed: () => showFilterModal(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
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
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar profesor...',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search,
                                color: themeProvider.currentTheme.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredProfessors.length,
                          itemBuilder: (context, index) {
                            final professor = filteredProfessors[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 46.0,
                                  bottom: 8.0,
                                  top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    width: 2.5, // Grosor aumentado
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        themeProvider.currentTheme.primaryColor,
                                    child: Text(
                                      professor['nombre'][0],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    professor['nombre'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider
                                          .currentTheme.primaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    professor['academia'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      color: themeProvider
                                          .currentTheme.primaryColor),
                                  onTap: () {
                                    print("Profesor seleccionado: $professor");
                                    Navigator.pushNamed(
                                      context,
                                      '/professorDetails',
                                      arguments: {
                                        ...professor,
                                        'numeroEmpleado':
                                            professor['num_empleado'],
                                      },
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
                Positioned(
                  right: 5.0,
                  top: 100.0,
                  bottom: 20.0,
                  child: Container(
                    width: 30.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.currentTheme.primaryColor,
                        width: 2.5, // Grosor aumentado
                      ),
                    ),
                    child: ListView(
                      children: ["ALL"]
                          .followedBy(List.generate(
                              26, (i) => String.fromCharCode(65 + i)))
                          .followedBy(["Á"])
                          .map(
                            (letter) => GestureDetector(
                              onTap: () => filterByLetter(letter),
                              child: Container(
                                height: 28.0,
                                alignment: Alignment.center,
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
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
