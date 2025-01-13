import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessorDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? professor =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Verificar que se hayan pasado los datos del profesor
    if (professor == null || professor['numeroEmpleado'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Profesor'),
        ),
        body: const Center(
          child: Text('No se proporcionaron datos del profesor.'),
        ),
      );
    }

    final String numeroEmpleado = professor['numeroEmpleado'];
    final theme = Theme.of(context);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('profesores')
          .where('num_empleado', isEqualTo: numeroEmpleado)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty
              ? snapshot.docs.first
              : throw Exception('No se encontró el profesor.')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.primaryColor,
              title: const Text('Detalles del Profesor',
                  style: TextStyle(color: Colors.white)),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.primaryColor,
              title: const Text('Detalles del Profesor',
                  style: TextStyle(color: Colors.white)),
            ),
            body: const Center(child: Text('No se encontró el profesor.')),
          );
        }

        // Datos del profesor desde Firebase
        final professorData = snapshot.data!.data() as Map<String, dynamic>;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('horarios')
              .where('num_profe', isEqualTo: numeroEmpleado)
              .get(),
          builder: (context, horariosSnapshot) {
            if (horariosSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: theme.primaryColor,
                  title: const Text('Detalles del Profesor',
                      style: TextStyle(color: Colors.white)),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (!horariosSnapshot.hasData ||
                horariosSnapshot.data!.docs.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: theme.primaryColor,
                  title: const Text('Detalles del Profesor',
                      style: TextStyle(color: Colors.white)),
                ),
                body: const Center(
                    child: Text('No se encontraron horarios para el profesor.')),
              );
            }

            // Obtener los horarios desde Firebase
            final horarios = horariosSnapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                "Grupo": data['grupo'] ?? 'No disponible',
                "Materia": data['uni_aprend'] ?? 'No disponible',
                "Salón": data['salon'] ?? 'No disponible',
                "Laboratorio": data['laboratorio'] ?? 'No disponible',
                "Lunes": data['lunes'] == '0:00' ? '-' : data['lunes'] ?? '-',
                "Martes":
                    data['martes'] == '0:00' ? '-' : data['martes'] ?? '-',
                "Miércoles": data['miercoles'] == '0:00'
                    ? '-'
                    : data['miercoles'] ?? '-',
                "Jueves":
                    data['jueves'] == '0:00' ? '-' : data['jueves'] ?? '-',
                "Viernes":
                    data['viernes'] == '0:00' ? '-' : data['viernes'] ?? '-',
              };
            }).toList();

            final List<Map<String, String>> materias = horarios.map((horario) {
              return {
                "Grupo": (horario["Grupo"] ?? "No disponible").toString(),
                "Materia": (horario["Materia"] ?? "No disponible").toString(),
                "Salón": (horario["Salón"] ?? "No disponible").toString(),
                "Laboratorio":
                    (horario["Laboratorio"] ?? "No disponible").toString(),
              };
            }).toList();

            final List<Map<String, String>> horarioTable =
                horarios.map((horario) {
              return {
                "Lunes": (horario["Lunes"] ?? "-").toString(),
                "Martes": (horario["Martes"] ?? "-").toString(),
                "Miércoles": (horario["Miércoles"] ?? "-").toString(),
                "Jueves": (horario["Jueves"] ?? "-").toString(),
                "Viernes": (horario["Viernes"] ?? "-").toString(),
              };
            }).toList();

            return Scaffold(
              appBar: AppBar(
                backgroundColor: theme.primaryColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Detalles del Profesor',
                    style: TextStyle(color: Colors.white)),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.secondary,
                        child: Icon(Icons.person,
                            size: 60, color: theme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        professorData['nombre'] ?? 'Sin Nombre',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        professorData['academia'] ?? 'Sin Academia',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: theme.primaryColor, thickness: 1.5),
                      const SizedBox(height: 16),
                      buildDetailRow(
                        icon: Icons.email,
                        title: "Correo Electrónico",
                        value: professorData['correo'] ?? 'No disponible',
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      buildDetailRow(
                        icon: Icons.location_on,
                        title: "Cubículo",
                        value: professorData['cubiculo'] ?? 'No disponible',
                        theme: theme,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Materias",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      buildRoundedTable(
                        headers: [
                          "ID",
                          "Grupo",
                          "Materia",
                          "Salón",
                          "Laboratorio"
                        ],
                        data: materias,
                        theme: theme,
                        columnWidths: {
                          0: FixedColumnWidth(40), // ID (más pequeña)
                          1: FlexColumnWidth(2), // Grupo
                          2: FlexColumnWidth(3), // Materia
                          3: FlexColumnWidth(2), // Salón
                          4: FlexColumnWidth(3), // Laboratorio (más grande)
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Horario",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      buildRoundedTable(
                        headers: [
                          "ID",
                          "Lunes",
                          "Martes",
                          "Miércoles",
                          "Jueves",
                          "Viernes"
                        ],
                        data: horarioTable,
                        theme: theme,
                        columnWidths: {
                          0: FixedColumnWidth(20), // ID
                          1: FlexColumnWidth(3), // Lunes
                          2: FlexColumnWidth(3), // Martes
                          3: FlexColumnWidth(4), // Miércoles (más grande)
                          4: FlexColumnWidth(3), // Jueves
                          5: FlexColumnWidth(3), // Viernes
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRoundedTable({
    required List<String> headers,
    required List<Map<String, String>> data,
    required ThemeData theme,
    required Map<int, TableColumnWidth> columnWidths,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor, width: 1.5),
      ),
      child: Table(
        columnWidths: columnWidths,
        border:
            TableBorder.all(color: Colors.transparent), // Sin líneas divisorias
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            children: headers
                .map((header) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        header,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
          ...List.generate(
            data.length,
            (index) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...data[index].values.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cell,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
