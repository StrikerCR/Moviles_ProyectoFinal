import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para generar números aleatorios

Future<void> insertDatos() async {
  try {
    // Referencia a la colección de profesores
    final CollectionReference profesoresCollection =
        FirebaseFirestore.instance.collection('profesores');

    // Obtiene todos los documentos de la colección
    final QuerySnapshot querySnapshot = await profesoresCollection.get();

    for (var doc in querySnapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('nombre')) {
        final String nombreCompleto = data['nombre'];

        // Genera el correo electrónico basado en el nombre completo
        final String correo = generarCorreoDesdeNombre(nombreCompleto);

        // Actualiza el documento con el nuevo correo
        await profesoresCollection.doc(doc.id).update({'correo': correo});
        print("Correo actualizado para ${nombreCompleto}: $correo");
      } else {
        print("El documento ${doc.id} no tiene un campo 'nombre'.");
      }
    }

    print("Actualización de correos completada.");
  } catch (e) {
    print("Error al actualizar los correos: $e");
  }
}

String generarCorreoDesdeNombre(String nombreCompleto) {
  // Convierte el nombre completo en minúsculas
  String nombre = nombreCompleto.toLowerCase();

  // Reemplaza caracteres especiales
  nombre = nombre
      .replaceAll(RegExp(r'[áÁ]'), 'a')
      .replaceAll(RegExp(r'[éÉ]'), 'e')
      .replaceAll(RegExp(r'[íÍ]'), 'i')
      .replaceAll(RegExp(r'[óÓ]'), 'o')
      .replaceAll(RegExp(r'[úÚ]'), 'u')
      .replaceAll(RegExp(r'[ñÑ]'), 'n');

  // Divide el nombre en palabras
  final List<String> palabras = nombre.split(' ');

  // Variables auxiliares para construir el correo
  String inicialPrimerNombre = '';
  String primerApellido = '';
  String inicialSegundoApellido = '';
  final Random random = Random();
  final int numeroAleatorio = random.nextInt(90) + 10; // Número aleatorio 10-99

  // Asignar inicial del primer nombre si existe
  if (palabras.isNotEmpty) {
    inicialPrimerNombre = palabras[0][0];
  }

  // Asignar primer apellido completo si existe
  if (palabras.length > 1) {
    primerApellido = palabras[1];
  }

  // Asignar inicial del segundo apellido si existe
  if (palabras.length > 2) {
    inicialSegundoApellido = palabras[2][0];
  }

  // Construir el correo basado en los datos disponibles
  if (inicialPrimerNombre.isNotEmpty && primerApellido.isNotEmpty) {
    return '$inicialPrimerNombre$primerApellido$inicialSegundoApellido$numeroAleatorio@example.com';
  } else {
    // Si no hay suficiente información, retornar un correo genérico
    return 'correo-generico@example.com';
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:math';

Future<void> insertDatos() async {
  try {
    // Ruta al archivo Excel en assets
    final String filePath = 'assets/DCIC_20242_version_correcta.xlsx';

    // Leer el archivo Excel desde assets
    final ByteData data = await rootBundle.load(filePath);
    final bytes = data.buffer.asUint8List();
 
    // Decodificar el archivo Excel
    var excel = Excel.decodeBytes(bytes);

    // Seleccionar la primera hoja
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      print("No se encontró la hoja en el archivo Excel.");
      return;
    }

    // Referencia a la colección "horarios" en Firestore
    final CollectionReference horariosCollection =
        FirebaseFirestore.instance.collection('horarios');

    // Obtener los números de empleado de los profesores en Firebase
    final QuerySnapshot profesoresSnapshot =
        await FirebaseFirestore.instance.collection('profesores').get();
    final Map<String, String> profesorNumEmpleado = {
      for (var doc in profesoresSnapshot.docs)
        doc['nombre']: doc['num_empleado']
    };

    // Generar un salón aleatorio basado en la estructura de edificios, pisos y salones
    String generarSalon() {
      Random random = Random();
      int edificio = random.nextInt(3) + 1; // Edificio 1, 2 o 3
      int piso = random.nextInt(2); // Planta baja (0) o primer piso (1)
      int salon = random.nextInt(16) + 1; // Salones del 1 al 16
      return '$edificio$piso${salon.toString().padLeft(2, '0')}';
    }

    // Procesar los datos del Excel
    for (var i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];

      final String grupo = row[0]?.value?.toString()?.trim()?.toUpperCase() ?? '';
      final String uniAprend =
          row[1]?.value?.toString()?.trim()?.toUpperCase() ?? '';
      final String salon = row[2]?.value?.toString()?.trim()?.toUpperCase() ?? '';
      final String profesor =
          row[4]?.value?.toString()?.trim()?.toUpperCase() ?? '';
      final String laboratorio =
          row[5]?.value?.toString()?.trim()?.toUpperCase() ?? '';
      final String lunes = row[6]?.value?.toString()?.trim() ?? '0:00';
      final String martes = row[7]?.value?.toString()?.trim() ?? '0:00';
      final String miercoles = row[8]?.value?.toString()?.trim() ?? '0:00';
      final String jueves = row[9]?.value?.toString()?.trim() ?? '0:00';
      final String viernes = row[10]?.value?.toString()?.trim() ?? '0:00';

      // Saltar filas con encabezados o datos inválidos
      if (grupo == "GRUPO" ||
          uniAprend == "UNIDAD DE APRENDIZAJE" ||
          salon == "SALON" ||
          profesor == "SIN ASIGNAR" ||
          profesor == "PROFESOR") {
        continue;
      }

      // Obtener el número de empleado del profesor
      final String? numEmpleado = profesorNumEmpleado[profesor];
      if (numEmpleado == null) {
        print('Profesor no encontrado en Firebase: $profesor');
        continue;
      }

      // Generar un salón si no está especificado
      final String salonFinal = salon.isNotEmpty ? salon : generarSalon();

      // Crear el documento en Firebase
      await horariosCollection.add({
        'grupo': grupo,
        'uni_aprend': uniAprend,
        'salon': salonFinal,
        'num_profe': numEmpleado,
        'laboratorio': laboratorio,
        'lunes': lunes,
        'martes': martes,
        'miercoles': miercoles,
        'jueves': jueves,
        'viernes': viernes,
      });

      print('Horario agregado: $grupo - $uniAprend');
    }

    print('Horarios procesados exitosamente.');
  } catch (e) {
    print('Error al insertar horarios: $e');
  }
}
*/

/* agregar profesores
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:math';

Future<void> insertDatos() async {
  try {
    // Ruta al archivo Excel en assets
    final String filePath = 'assets/DCIC_20242_version_correcta.xlsx';

    // Leer el archivo Excel desde assets
    final ByteData data = await rootBundle.load(filePath);
    final bytes = data.buffer.asUint8List();

    // Decodificar el archivo Excel
    var excel = Excel.decodeBytes(bytes);

    // Seleccionar la primera hoja
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      print("No se encontró la hoja en el archivo Excel.");
      return;
    }

    // Referencia a la colección "profesores" en Firestore
    final CollectionReference profesoresCollection =
        FirebaseFirestore.instance.collection('profesores');

    // Mapeo de academias según palabras clave en la unidad de aprendizaje
    final Map<String, String> academias = {
      "Matemáticas": "Academia de Ciencia Básicas",
      "Comunicación": "Academia de Ciencias de la Comunicación",
      "Sociales": "Academia de Ciencias Sociales",
      "Sistemas Electrónicos": "Academia de Fundamentos de Sistemas Electrónicos",
      "Software": "Academia de Ingeniería de Software",
      "Proyectos Estratégicos": "Academia de Proyectos Estratégicos y Toma de Decisiones",
      "Sistemas Digitales": "Academia de Sistemas Digitales",
      "Distribuidos": "Academia de Sistemas Distribuidos",
      "Ciencia de Datos": "Academia de Ciencia de Datos",
      "Inteligencia Artificial": "Academia de Inteligencia Artificial"
    };

    // Función para determinar la academia con base en la unidad de aprendizaje
    String getAcademia(String unidadAprendizaje) {
      for (var key in academias.keys) {
        if (unidadAprendizaje.toLowerCase().contains(key.toLowerCase())) {
          return academias[key]!;
        }
      }
      return "Academia General";
    }

    // Generar una lista de cubículos disponibles
    List<String> cubiculos = List.generate(25, (index) => "Cubículo ${index + 1}");
    Random random = Random();

    // Procesar profesores sin duplicados
    Set<String> nombresProcesados = {};
    for (var i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
      final String profesor =
          row[4]?.value?.toString()?.trim()?.toUpperCase() ?? ''; // Columna de profesor
      final String unidadAprendizaje =
          row[1]?.value?.toString()?.trim() ?? ''; // Columna de unidad de aprendizaje

      // Ignorar "SIN ASIGNAR" y "PROFESOR"
      if (profesor.isNotEmpty && profesor != "PROFESOR" && profesor != "SIN ASIGNAR") {
        // Verificar si el profesor ya fue procesado
        if (!nombresProcesados.contains(profesor)) {
          nombresProcesados.add(profesor);

          // Verificar si el profesor ya existe en Firebase
          final QuerySnapshot existingDocs = await profesoresCollection
              .where('nombre', isEqualTo: profesor)
              .get();

          if (existingDocs.docs.isEmpty) {
            // Insertar al profesor si no existe
            final String numEmpleado =
                "E${10000 + nombresProcesados.length}"; // Generar número de empleado único
            final String academia = getAcademia(unidadAprendizaje);
            final String cubiculoAsignado = cubiculos[random.nextInt(cubiculos.length)];

            await profesoresCollection.add({
              'nombre': profesor,
              'num_empleado': numEmpleado,
              'contratación': "contratado",
              'academia': academia,
              'cubiculo': cubiculoAsignado,
            });

            print('Profesor agregado: $profesor');
          } else {
            print('Profesor ya existe: $profesor');
          }
        }
      } else {
        print('Profesor omitido: $profesor'); // Debugging para ver qué se omite
      }
    }

    print('Profesores procesados exitosamente.');
  } catch (e) {
    print('Error al insertar datos: $e');
  }
}
*/

/* grupos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

Future<void> insertDatos() async {
  try {
    // Ruta al archivo Excel en assets
    final String filePath = 'assets/DCIC_20242_version_correcta.xlsx';

    // Leer el archivo Excel desde assets
    final ByteData data = await rootBundle.load(filePath);
    final bytes = data.buffer.asUint8List();

    // Decodificar el archivo Excel
    var excel = Excel.decodeBytes(bytes);

    // Seleccionar la primera hoja
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      print("No se encontró la hoja en el archivo Excel.");
      return;
    }

    // Referencia a la colección "grupos" en Firestore
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('grupos');

    // Usar un conjunto para evitar duplicados locales
    Set<String> gruposUnicos = {};

    // Procesar cada fila del Excel (ignorando la cabecera)
    for (var i = 1; i < sheet.rows.length; i++) {
      var row = sheet.rows[i];
      final String grupo = row[0]?.value?.toString() ?? ''; // Columna de GRUPO

      if (grupo.isNotEmpty) {
        gruposUnicos.add(grupo);
      }
    }

    // Insertar los grupos únicos en Firestore
    for (var grupo in gruposUnicos) {
      // Verificar si el grupo ya existe en Firestore
      final QuerySnapshot existingDocs =
          await collection.where('nombre', isEqualTo: grupo).get();

      if (existingDocs.docs.isEmpty) {
        // Si no existe, agregarlo
        await collection.add({'nombre': grupo});
        print('Grupo agregado: $grupo');
      } else {
        print('Grupo ya existe: $grupo');
      }
    }

    print('Grupos únicos insertados exitosamente.');
  } catch (e) {
    print('Error al insertar datos: $e');
  }
}*/

/*
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> insertDatos() async {
  // Lista de directivos como mapas
  final List<Map<String, dynamic>> alumnos = [
    {
        "numBoleta": "2024630001",
        "curp": "ABCD123456EFGHIJ01",
        "nombre_es": "LUIS RAMON",
        "apePater_es": "SERRANO",
        "apeMater_es": "CEBALLOS",
        "carrera": "ISC",
        "correo": "luis_ramon0001@example.com",
        "contraseña": "IrOPApqS"
    },
    {
        "numBoleta": "2024630002",
        "curp": "ABCD123456EFGHIJ02",
        "nombre_es": "JORGE ARMANDO",
        "apePater_es": "ARTEAGA",
        "apeMater_es": "ROCHA",
        "carrera": "ISC",
        "correo": "jorge_armando0002@example.com",
        "contraseña": "bMhUjx6s"
    },
    {
        "numBoleta": "2024630003",
        "curp": "ABCD123456EFGHIJ03",
        "nombre_es": "RAUL",
        "apePater_es": "MONTOYA",
        "apeMater_es": "DE SANTIAGO",
        "carrera": "ISC",
        "correo": "raul0003@example.com",
        "contraseña": "hpKyrjzZ"
    },
    {
        "numBoleta": "2024630004",
        "curp": "ABCD123456EFGHIJ04",
        "nombre_es": "ALDRICH JONATHAN",
        "apePater_es": "AVILA",
        "apeMater_es": "SANCHEZ",
        "carrera": "ISC",
        "correo": "aldrich_jonathan0004@example.com",
        "contraseña": "jPlWLOZ6"
    },
    {
        "numBoleta": "2024630005",
        "curp": "ABCD123456EFGHIJ05",
        "nombre_es": "DAVID",
        "apePater_es": "TORRES",
        "apeMater_es": "RAMIREZ",
        "carrera": "ISC",
        "correo": "david0005@example.com",
        "contraseña": "ubwqRITJ"
    },
    {
        "numBoleta": "2024630006",
        "curp": "ABCD123456EFGHIJ06",
        "nombre_es": "JESSE OBED",
        "apePater_es": "SAUCILLO",
        "apeMater_es": "GONZALEZ",
        "carrera": "IIA",
        "correo": "jesse_obed0006@example.com",
        "contraseña": "qhRESJ22"
    },
    {
        "numBoleta": "2024630007",
        "curp": "ABCD123456EFGHIJ07",
        "nombre_es": "MIGUEL ANGEL",
        "apePater_es": "RODRIGUEZ",
        "apeMater_es": "TORRES",
        "carrera": "ISC",
        "correo": "miguel_angel0007@example.com",
        "contraseña": "tBd9EQ26"
    },
    {
        "numBoleta": "2024630008",
        "curp": "ABCD123456EFGHIJ08",
        "nombre_es": "FLAVIO JOSUE",
        "apePater_es": "SANCHEZ",
        "apeMater_es": "DE LOS RIOS",
        "carrera": "IIA",
        "correo": "flavio_josue0008@example.com",
        "contraseña": "ydRZWw8K"
    },
    {
        "numBoleta": "2024630009",
        "curp": "ABCD123456EFGHIJ09",
        "nombre_es": "GUILLERMO",
        "apePater_es": "PINEDA",
        "apeMater_es": "CUELLAR",
        "carrera": "ISC",
        "correo": "guillermo0009@example.com",
        "contraseña": "2AmLNNvd"
    },
    {
        "numBoleta": "2024630010",
        "curp": "ABCD123456EFGHIJ10",
        "nombre_es": "DANIEL SAID",
        "apePater_es": "AVILA",
        "apeMater_es": "MEJIA",
        "carrera": "ISC",
        "correo": "daniel_said0010@example.com",
        "contraseña": "SOX8Ht5y"
    },
    {
        "numBoleta": "2024630011",
        "curp": "ABCD123456EFGHIJ11",
        "nombre_es": "LUIS JESUS",
        "apePater_es": "NAVA",
        "apeMater_es": "CLEMENTE",
        "carrera": "ISC",
        "correo": "luis_jesus0011@example.com",
        "contraseña": "vm6E9P2s"
    },
    {
        "numBoleta": "2024630012",
        "curp": "ABCD123456EFGHIJ12",
        "nombre_es": "BRANDON ANTONIO",
        "apePater_es": "CAMPERO",
        "apeMater_es": "BELECHE",
        "carrera": "ISC",
        "correo": "brandon_antonio0012@example.com",
        "contraseña": "PgWlcCbx"
    },
    {
        "numBoleta": "2024630013",
        "curp": "ABCD123456EFGHIJ13",
        "nombre_es": "BRENDA",
        "apePater_es": "VERGARA",
        "apeMater_es": "MARTINEZ",
        "carrera": "ISC",
        "correo": "brenda0013@example.com",
        "contraseña": "6bd4FXlA"
    },
    {
        "numBoleta": "2024630014",
        "curp": "ABCD123456EFGHIJ14",
        "nombre_es": "PEDRO ABRAHAM",
        "apePater_es": "MOYA",
        "apeMater_es": "MANCILLA",
        "carrera": "ISC",
        "correo": "pedro_abraham0014@example.com",
        "contraseña": "AEPsnSgk"
    },
    {
        "numBoleta": "2024630015",
        "curp": "ABCD123456EFGHIJ15",
        "nombre_es": "KEVYN ALEJANDRO",
        "apePater_es": "PEREZ",
        "apeMater_es": "LUCIO",
        "carrera": "IIA",
        "correo": "kevyn_alejandro0015@example.com",
        "contraseña": "4Irzf8SO"
    },
    {
        "numBoleta": "2024630016",
        "curp": "ABCD123456EFGHIJ16",
        "nombre_es": "JUAN LUIS",
        "apePater_es": "MOLINA",
        "apeMater_es": "ACUÑA",
        "carrera": "ISC",
        "correo": "juan_luis0016@example.com",
        "contraseña": "siKpwujF"
    },
    {
        "numBoleta": "2024630017",
        "curp": "ABCD123456EFGHIJ17",
        "nombre_es": "TABATHA DUBHE",
        "apePater_es": "AXOTLA",
        "apeMater_es": "GONZALEZ",
        "carrera": "ISC",
        "correo": "tabatha_dubhe0017@example.com",
        "contraseña": "TSNJIHov"
    },
    {
        "numBoleta": "2024630018",
        "curp": "ABCD123456EFGHIJ18",
        "nombre_es": "IRMIN YAEL",
        "apePater_es": "SANCHEZ",
        "apeMater_es": "RODRIGUEZ",
        "carrera": "IIA",
        "correo": "irmin_yael0018@example.com",
        "contraseña": "Jp1RXM0U"
    },
    {
        "numBoleta": "2024630019",
        "curp": "ABCD123456EFGHIJ19",
        "nombre_es": "ERANDI GUADALUPE",
        "apePater_es": "RAMIREZ",
        "apeMater_es": "AYALA",
        "carrera": "ISC",
        "correo": "erandi_guadalupe0019@example.com",
        "contraseña": "3IF6UUvt"
    },
    {
        "numBoleta": "2024630020",
        "curp": "ABCD123456EFGHIJ20",
        "nombre_es": "RODRIGO",
        "apePater_es": "ORTIZ",
        "apeMater_es": "MARIN",
        "carrera": "IIA",
        "correo": "rodrigo0020@example.com",
        "contraseña": "3d2T5bgN"
    },
    {
        "numBoleta": "2024630021",
        "curp": "ABCD123456EFGHIJ21",
        "nombre_es": "GIBHRAM",
        "apePater_es": "CASTRO",
        "apeMater_es": "RENDON",
        "carrera": "ISC",
        "correo": "gibhram0021@example.com",
        "contraseña": "kkg9cP72"
    },
    {
        "numBoleta": "2024630022",
        "curp": "ABCD123456EFGHIJ22",
        "nombre_es": "JULIAN",
        "apePater_es": "ALCIBAR",
        "apeMater_es": "ZUBILLAGA",
        "carrera": "LCD",
        "correo": "julian0022@example.com",
        "contraseña": "O7YrDCvv"
    },
    {
        "numBoleta": "2024630023",
        "curp": "ABCD123456EFGHIJ23",
        "nombre_es": "MARCO ANTONIO",
        "apePater_es": "CRUZ",
        "apeMater_es": "GOMEZ",
        "carrera": "ISC",
        "correo": "marco_antonio0023@example.com",
        "contraseña": "OILg99Ar"
    },
    {
        "numBoleta": "2024630024",
        "curp": "ABCD123456EFGHIJ24",
        "nombre_es": "ITZEL",
        "apePater_es": "FLORES",
        "apeMater_es": "PATIÑO",
        "carrera": "ISC",
        "correo": "itzel0024@example.com",
        "contraseña": "aDWHRkbd"
    },
    {
        "numBoleta": "2024630025",
        "curp": "ABCD123456EFGHIJ25",
        "nombre_es": "JAYRI ARATH",
        "apePater_es": "FUENTES",
        "apeMater_es": "REYES",
        "carrera": "ISC",
        "correo": "jayri_arath0025@example.com",
        "contraseña": "30UapR0L"
    },
    {
        "numBoleta": "2024630026",
        "curp": "ABCD123456EFGHIJ26",
        "nombre_es": "CINTHIA NAYELLI",
        "apePater_es": "GUTIERREZ",
        "apeMater_es": "JIMENEZ",
        "carrera": "ISC",
        "correo": "cinthia_nayelli0026@example.com",
        "contraseña": "M7oP6DEX"
    },
    {
        "numBoleta": "2024630027",
        "curp": "ABCD123456EFGHIJ27",
        "nombre_es": "SAUL",
        "apePater_es": "HERNANDEZ",
        "apeMater_es": "ALONSO",
        "carrera": "ISC",
        "correo": "saul0027@example.com",
        "contraseña": "abFSWmFV"
    },
    {
        "numBoleta": "2024630028",
        "curp": "ABCD123456EFGHIJ28",
        "nombre_es": "CESAR ALEJANDRO",
        "apePater_es": "LECHUGA",
        "apeMater_es": "CERVANTES",
        "carrera": "ISC",
        "correo": "cesar_alejandro0028@example.com",
        "contraseña": "xzksiWUs"
    },
    {
        "numBoleta": "2024630029",
        "curp": "ABCD123456EFGHIJ29",
        "nombre_es": "LUIS ANTONIO",
        "apePater_es": "MONTOYA",
        "apeMater_es": "MORALES",
        "carrera": "ISC",
        "correo": "luis_antonio0029@example.com",
        "contraseña": "f0tuykc0"
    },
    {
        "numBoleta": "2024630030",
        "curp": "ABCD123456EFGHIJ30",
        "nombre_es": "EZEQUIEL NAHUN",
        "apePater_es": "PEREZ",
        "apeMater_es": "CARBAJAL",
        "carrera": "ISC",
        "correo": "ezequiel_nahun0030@example.com",
        "contraseña": "tjhKpB0q"
    },
    {
        "numBoleta": "2024630031",
        "curp": "ABCD123456EFGHIJ31",
        "nombre_es": "CARLOS JARED",
        "apePater_es": "LOPEZ",
        "apeMater_es": "DEL CARMEN",
        "carrera": "ISC",
        "correo": "carlos_jared0031@example.com",
        "contraseña": "IK297mob"
    },
    {
        "numBoleta": "2024630032",
        "curp": "ABCD123456EFGHIJ32",
        "nombre_es": "ALBERTO",
        "apePater_es": "PLATA",
        "apeMater_es": "GONZALEZ",
        "carrera": "LCD",
        "correo": "alberto0032@example.com",
        "contraseña": "vxJprg2Z"
    },
    {
        "numBoleta": "2024630033",
        "curp": "ABCD123456EFGHIJ33",
        "nombre_es": "ARTURO",
        "apePater_es": "MONROY",
        "apeMater_es": "MORA",
        "carrera": "ISC",
        "correo": "arturo0033@example.com",
        "contraseña": "ZErQg1NW"
    },
    {
        "numBoleta": "2024630034",
        "curp": "ABCD123456EFGHIJ34",
        "nombre_es": "JESUS EDUARDO",
        "apePater_es": "SOLIS",
        "apeMater_es": "GONZALEZ",
        "carrera": "ISC",
        "correo": "jesus_eduardo0034@example.com",
        "contraseña": "wwgIdlfL"
    },
    {
        "numBoleta": "2024630035",
        "curp": "ABCD123456EFGHIJ35",
        "nombre_es": "ERIK ENRIQUE",
        "apePater_es": "RIVERA",
        "apeMater_es": "PONCE",
        "carrera": "ISC",
        "correo": "erik_enrique0035@example.com",
        "contraseña": "rsi69Ord"
    },
    {
        "numBoleta": "2024630036",
        "curp": "ABCD123456EFGHIJ36",
        "nombre_es": "ARTURO",
        "apePater_es": "ROJAS",
        "apeMater_es": "CERVANTES",
        "carrera": "ISC",
        "correo": "arturo0036@example.com",
        "contraseña": "D4LAURHV"
    },
    {
        "numBoleta": "2024630037",
        "curp": "ABCD123456EFGHIJ37",
        "nombre_es": "BRIAN JULIAN",
        "apePater_es": "CALVA",
        "apeMater_es": "GONZALEZ",
        "carrera": "IIA",
        "correo": "brian_julian0037@example.com",
        "contraseña": "xf9acUDR"
    },
    {
        "numBoleta": "2024630038",
        "curp": "ABCD123456EFGHIJ38",
        "nombre_es": "ADRIAN",
        "apePater_es": "RAMIREZ",
        "apeMater_es": "RAMIREZ",
        "carrera": "LCD",
        "correo": "adrian0038@example.com",
        "contraseña": "keYbZI6c"
    },
    {
        "numBoleta": "2024630039",
        "curp": "ABCD123456EFGHIJ39",
        "nombre_es": "YAHAIDA MICHELLE",
        "apePater_es": "RAMIREZ",
        "apeMater_es": "VAZQUEZ",
        "carrera": "ISC",
        "correo": "yahaida_michelle0039@example.com",
        "contraseña": "RcqfZEB7"
    },
    {
        "numBoleta": "2024630040",
        "curp": "ABCD123456EFGHIJ40",
        "nombre_es": "ERIC DANIEL",
        "apePater_es": "LEGARIA",
        "apeMater_es": "AGAPITO",
        "carrera": "ISC",
        "correo": "eric_daniel0040@example.com",
        "contraseña": "tJJJ89Dg"
    },
    {
        "numBoleta": "2024630041",
        "curp": "ABCD123456EFGHIJ41",
        "nombre_es": "JOSE LUIS",
        "apePater_es": "RODRIGUEZ",
        "apeMater_es": "VILLEGAS",
        "carrera": "ISC",
        "correo": "jose_luis0041@example.com",
        "contraseña": "bg3Yrmhs"
    },
    {
        "numBoleta": "2024630042",
        "curp": "ABCD123456EFGHIJ42",
        "nombre_es": "GABRIEL ALBERTO",
        "apePater_es": "MORENO",
        "apeMater_es": "ROJAS",
        "carrera": "ISC",
        "correo": "gabriel_alberto0042@example.com",
        "contraseña": "AC3HqmM3"
    },
    {
        "numBoleta": "2024630043",
        "curp": "ABCD123456EFGHIJ43",
        "nombre_es": "FERNANDO ROBERTO",
        "apePater_es": "MAGALLANES",
        "apeMater_es": "RETANA",
        "carrera": "ISC",
        "correo": "fernando_roberto0043@example.com",
        "contraseña": "fLymvPoE"
    },
    {
        "numBoleta": "2024630044",
        "curp": "ABCD123456EFGHIJ44",
        "nombre_es": "ALEJANDRA",
        "apePater_es": "GUZMAN",
        "apeMater_es": "JIMENEZ",
        "carrera": "ISC",
        "correo": "alejandra0044@example.com",
        "contraseña": "WSrTip6V"
    },
    {
        "numBoleta": "2024630045",
        "curp": "ABCD123456EFGHIJ45",
        "nombre_es": "FERNANDO",
        "apePater_es": "REYES",
        "apeMater_es": "VIVAR",
        "carrera": "ISC",
        "correo": "fernando0045@example.com",
        "contraseña": "hvC0eYHy"
    },
    {
        "numBoleta": "2024630046",
        "curp": "ABCD123456EFGHIJ46",
        "nombre_es": "OSCAR DANIEL",
        "apePater_es": "BUCIO",
        "apeMater_es": "BARRERA",
        "carrera": "ISC",
        "correo": "oscar_daniel0046@example.com",
        "contraseña": "jQQcKuuJ"
    },
    {
        "numBoleta": "2024630047",
        "curp": "ABCD123456EFGHIJ47",
        "nombre_es": "PABLO DARIO",
        "apePater_es": "JUAREZ",
        "apeMater_es": "SANCHEZ",
        "carrera": "LCD",
        "correo": "pablo_dario0047@example.com",
        "contraseña": "0RXlveca"
    },
    {
        "numBoleta": "2024630048",
        "curp": "ABCD123456EFGHIJ48",
        "nombre_es": "OSMAR ALEJANDRO",
        "apePater_es": "GARCIA",
        "apeMater_es": "JIMENEZ",
        "carrera": "ISC",
        "correo": "osmar_alejandro0048@example.com",
        "contraseña": "F5zCQHib"
    },
    {
        "numBoleta": "2024630049",
        "curp": "ABCD123456EFGHIJ49",
        "nombre_es": "DIEGO",
        "apePater_es": "MARTINEZ",
        "apeMater_es": "MENDEZ",
        "carrera": "IIA",
        "correo": "diego0049@example.com",
        "contraseña": "8KH9qzPV"
    },
    {
        "numBoleta": "2024630050",
        "curp": "ABCD123456EFGHIJ50",
        "nombre_es": "AXEL ULYSSES",
        "apePater_es": "ROBLES",
        "apeMater_es": "VELAZQUEZ",
        "carrera": "ISC",
        "correo": "axel_ulysses0050@example.com",
        "contraseña": "vpcOIIOL"
    },
    {
        "numBoleta": "2024630051",
        "curp": "ABCD123456EFGHIJ51",
        "nombre_es": "GIOVANNI JAVIER",
        "apePater_es": "LONGORIA",
        "apeMater_es": "BUNOUST",
        "carrera": "ISC",
        "correo": "giovanni_javier0051@example.com",
        "contraseña": "K3FOrki5"
    },
    {
        "numBoleta": "2024630052",
        "curp": "ABCD123456EFGHIJ52",
        "nombre_es": "JARED",
        "apePater_es": "CASTILLO",
        "apeMater_es": "GONZALEZ",
        "carrera": "ISC",
        "correo": "jared0052@example.com",
        "contraseña": "n3lZLfbd"
    },
    {
        "numBoleta": "2024630053",
        "curp": "ABCD123456EFGHIJ53",
        "nombre_es": "ARANZA ALONDRA",
        "apePater_es": "MUÑOZ",
        "apeMater_es": "CHAVEZ",
        "carrera": "ISC",
        "correo": "aranza_alondra0053@example.com",
        "contraseña": "Omd9mBcf"
    },
    {
        "numBoleta": "2024630054",
        "curp": "ABCD123456EFGHIJ54",
        "nombre_es": "SERGIO IVAN",
        "apePater_es": "PANIAGUA",
        "apeMater_es": "ARROYO",
        "carrera": "ISC",
        "correo": "sergio_ivan0054@example.com",
        "contraseña": "q4BKSp6d"
    },
    {
        "numBoleta": "2024630055",
        "curp": "ABCD123456EFGHIJ55",
        "nombre_es": "JAVIER",
        "apePater_es": "ZAMARRON",
        "apeMater_es": "RAMIREZ",
        "carrera": "ISC",
        "correo": "javier0055@example.com",
        "contraseña": "VmoLGjTV"
    },
    {
        "numBoleta": "2024630056",
        "curp": "ABCD123456EFGHIJ56",
        "nombre_es": "HECTOR",
        "apePater_es": "RUIZ",
        "apeMater_es": "HERNANDEZ",
        "carrera": "ISC",
        "correo": "hector0056@example.com",
        "contraseña": "YVEMAbKi"
    },
    {
        "numBoleta": "2024630057",
        "curp": "ABCD123456EFGHIJ57",
        "nombre_es": "ERIC OMAR",
        "apePater_es": "ESPINOSA DE LOS MONTEROS",
        "apeMater_es": "MARTINEZ",
        "carrera": "ISC",
        "correo": "eric_omar0057@example.com",
        "contraseña": "GQi9luKm"
    },
    {
        "numBoleta": "2024630058",
        "curp": "ABCD123456EFGHIJ58",
        "nombre_es": "CARLOS",
        "apePater_es": "MORENO",
        "apeMater_es": "HERNANDEZ",
        "carrera": "ISC",
        "correo": "carlos0058@example.com",
        "contraseña": "dZt4XrkB"
    },
    {
        "numBoleta": "2024630059",
        "curp": "ABCD123456EFGHIJ59",
        "nombre_es": "GUSTAVO ADOLFO",
        "apePater_es": "ARREOLA",
        "apeMater_es": "ROJAS",
        "carrera": "ISC",
        "correo": "gustavo_adolfo0059@example.com",
        "contraseña": "G1XF8yXO"
    },
    {
        "numBoleta": "2024630060",
        "curp": "ABCD123456EFGHIJ60",
        "nombre_es": "ANTONIO DE JESUS",
        "apePater_es": "DOMINGUEZ",
        "apeMater_es": "ORTEGA",
        "carrera": "ISC",
        "correo": "antonio_de_jesus0060@example.com",
        "contraseña": "qgJmTAXq"
    },
    {
        "numBoleta": "2024630061",
        "curp": "ABCD123456EFGHIJ61",
        "nombre_es": "DIEGO FRANCISCO",
        "apePater_es": "HERNANDEZ",
        "apeMater_es": "PEREZ",
        "carrera": "ISC",
        "correo": "diego_francisco0061@example.com",
        "contraseña": "Uh8ff2jA"
    },
    {
        "numBoleta": "2024630062",
        "curp": "ABCD123456EFGHIJ62",
        "nombre_es": "MIGUEL ANGEL",
        "apePater_es": "RAFAEL",
        "apeMater_es": "VILLAFUERTE",
        "carrera": "ISC",
        "correo": "miguel_angel0062@example.com",
        "contraseña": "3OUTyhz2"
    },
    {
        "numBoleta": "2024630063",
        "curp": "ABCD123456EFGHIJ63",
        "nombre_es": "OSCAR ALESSANDRO",
        "apePater_es": "OSTOA",
        "apeMater_es": "VELASCO",
        "carrera": "ISC",
        "correo": "oscar_alessandro0063@example.com",
        "contraseña": "qONAK5GX"
    },
    {
        "numBoleta": "2024630064",
        "curp": "ABCD123456EFGHIJ64",
        "nombre_es": "JESUS ADIEL",
        "apePater_es": "GARCIA",
        "apeMater_es": "VELAZQUEZ",
        "carrera": "ISC",
        "correo": "jesus_adiel0064@example.com",
        "contraseña": "LHPJWn0v"
    },
    {
        "numBoleta": "2024630065",
        "curp": "ABCD123456EFGHIJ65",
        "nombre_es": "JONATHAN GERARDO",
        "apePater_es": "AVIÑA",
        "apeMater_es": "CALDERON",
        "carrera": "ISC",
        "correo": "jonathan_gerardo0065@example.com",
        "contraseña": "PiwA9P53"
    },
    {
        "numBoleta": "2024630066",
        "curp": "ABCD123456EFGHIJ66",
        "nombre_es": "BRENDA SAMANTHA",
        "apePater_es": "PEREZ",
        "apeMater_es": "BEDOLLA",
        "carrera": "IIA",
        "correo": "brenda_samantha0066@example.com",
        "contraseña": "euTg3ve2"
    },
    {
        "numBoleta": "2024630067",
        "curp": "ABCD123456EFGHIJ67",
        "nombre_es": "MARIO CESAR",
        "apePater_es": "MONROY",
        "apeMater_es": "HERNANDEZ",
        "carrera": "ISC",
        "correo": "mario_cesar0067@example.com",
        "contraseña": "xUojoote"
    },
    {
        "numBoleta": "2024630068",
        "curp": "ABCD123456EFGHIJ68",
        "nombre_es": "MARIANA",
        "apePater_es": "JIMENEZ",
        "apeMater_es": "GUERRERO",
        "carrera": "ISC",
        "correo": "mariana0068@example.com",
        "contraseña": "3lVYWyDF"
    },
    {
        "numBoleta": "2024630069",
        "curp": "ABCD123456EFGHIJ69",
        "nombre_es": "CALEB",
        "apePater_es": "GAMIZ",
        "apeMater_es": "GONZALEZ",
        "carrera": "ISC",
        "correo": "caleb0069@example.com",
        "contraseña": "qjrHjqUi"
    },
    {
        "numBoleta": "2024630070",
        "curp": "ABCD123456EFGHIJ70",
        "nombre_es": "ERIK",
        "apePater_es": "ALCANTARA",
        "apeMater_es": "COVARRUBIAS",
        "carrera": "ISC",
        "correo": "erik0070@example.com",
        "contraseña": "oTP5Bz65"
    },
    {
        "numBoleta": "2024630071",
        "curp": "ABCD123456EFGHIJ71",
        "nombre_es": "ALDO ALEJANDRO",
        "apePater_es": "ARCOS",
        "apeMater_es": "HERMIDA",
        "carrera": "ISC",
        "correo": "aldo_alejandro0071@example.com",
        "contraseña": "0TGM6k6k"
    },
    {
        "numBoleta": "2024630072",
        "curp": "ABCD123456EFGHIJ72",
        "nombre_es": "BRAYAN JAVIER",
        "apePater_es": "AGUIRRE",
        "apeMater_es": "ORTIZ",
        "carrera": "ISC",
        "correo": "brayan_javier0072@example.com",
        "contraseña": "gjzJdo1K"
    },
    {
        "numBoleta": "2024630073",
        "curp": "ABCD123456EFGHIJ73",
        "nombre_es": "CRISTIAN AXEL",
        "apePater_es": "BRAVO",
        "apeMater_es": "LOPEZ",
        "carrera": "ISC",
        "correo": "cristian_axel0073@example.com",
        "contraseña": "pa8sPPbr"
    },
    {
        "numBoleta": "2024630074",
        "curp": "ABCD123456EFGHIJ74",
        "nombre_es": "LUIS ANGEL",
        "apePater_es": "BERNAL",
        "apeMater_es": "PEREZ",
        "carrera": "ISC",
        "correo": "luis_angel0074@example.com",
        "contraseña": "fUT6xAvR"
    },
    {
        "numBoleta": "2024630075",
        "curp": "ABCD123456EFGHIJ75",
        "nombre_es": "DANIEL",
        "apePater_es": "ACEVEDO",
        "apeMater_es": "MEJIA",
        "carrera": "ISC",
        "correo": "daniel0075@example.com",
        "contraseña": "fYb30ur0"
    },
    {
        "numBoleta": "2024630076",
        "curp": "ABCD123456EFGHIJ76",
        "nombre_es": "EMILIANO",
        "apePater_es": "BAÑUELOS",
        "apeMater_es": "PEREZ",
        "carrera": "ISC",
        "correo": "emiliano0076@example.com",
        "contraseña": "lDryQ3UT"
    },
    {
        "numBoleta": "2024630077",
        "curp": "ABCD123456EFGHIJ77",
        "nombre_es": "JONATHAN DEMIAN",
        "apePater_es": "ANDRADE",
        "apeMater_es": "JIMENEZ",
        "carrera": "ISC",
        "correo": "jonathan_demian0077@example.com",
        "contraseña": "qasSoB4Y"
    },
    {
        "numBoleta": "2024630078",
        "curp": "ABCD123456EFGHIJ78",
        "nombre_es": "ALEJANDRO",
        "apePater_es": "CARBAJAL",
        "apeMater_es": "VELAZQUEZ",
        "carrera": "ISC",
        "correo": "alejandro0078@example.com",
        "contraseña": "PGTXOd16"
    },
    {
        "numBoleta": "2024630079",
        "curp": "ABCD123456EFGHIJ79",
        "nombre_es": "PEDRO",
        "apePater_es": "CRUZ",
        "apeMater_es": "VAZQUEZ",
        "carrera": "ISC",
        "correo": "pedro0079@example.com",
        "contraseña": "VVyt5Dbz"
    },
    {
        "numBoleta": "2024630080",
        "curp": "ABCD123456EFGHIJ80",
        "nombre_es": "DIEGO IVAN",
        "apePater_es": "CERVANTES",
        "apeMater_es": "HERNANDEZ",
        "carrera": "ISC",
        "correo": "diego_ivan0080@example.com",
        "contraseña": "SGYVAbsn"
    },
    {
        "numBoleta": "2024630081",
        "curp": "ABCD123456EFGHIJ81",
        "nombre_es": "EDGAR SEBASTIAN",
        "apePater_es": "CASTILLO",
        "apeMater_es": "SALGADO",
        "carrera": "ISC",
        "correo": "edgar_sebastian0081@example.com",
        "contraseña": "0Cr7mfX8"
    },
    {
        "numBoleta": "2024630082",
        "curp": "ABCD123456EFGHIJ82",
        "nombre_es": "EDMUNDO ALEJANDRO",
        "apePater_es": "CRUZ",
        "apeMater_es": "DE LA VEGA",
        "carrera": "ISC",
        "correo": "edmundo_alejandro0082@example.com",
        "contraseña": "NtJLTV3I"
    },
    {
        "numBoleta": "2024630083",
        "curp": "ABCD123456EFGHIJ83",
        "nombre_es": "LUIS ANGEL",
        "apePater_es": "CALDERON",
        "apeMater_es": "ZIMBRON",
        "carrera": "ISC",
        "correo": "luis_angel0083@example.com",
        "contraseña": "eE0yw4zJ"
    },
    {
        "numBoleta": "2024630084",
        "curp": "ABCD123456EFGHIJ84",
        "nombre_es": "DIEGO",
        "apePater_es": "CUREÑO",
        "apeMater_es": "CRUZ",
        "carrera": "ISC",
        "correo": "diego0084@example.com",
        "contraseña": "7ZN5BRCz"
    },
    {
        "numBoleta": "2024630085",
        "curp": "ABCD123456EFGHIJ85",
        "nombre_es": "NOE",
        "apePater_es": "CRUZ",
        "apeMater_es": "MEDRANO",
        "carrera": "ISC",
        "correo": "noe0085@example.com",
        "contraseña": "ZozhDbLX"
    },
    {
        "numBoleta": "2024630086",
        "curp": "ABCD123456EFGHIJ86",
        "nombre_es": "DEREK JACOB",
        "apePater_es": "COLIN",
        "apeMater_es": "ROMERO",
        "carrera": "ISC",
        "correo": "derek_jacob0086@example.com",
        "contraseña": "RCraBDaU"
    },
    {
        "numBoleta": "2024630087",
        "curp": "ABCD123456EFGHIJ87",
        "nombre_es": "LIZETH ABIGAIL",
        "apePater_es": "DAMIAN",
        "apeMater_es": "ELIZONDO",
        "carrera": "IIA",
        "correo": "lizeth_abigail0087@example.com",
        "contraseña": "XwtZzNIX"
    },
    {
        "numBoleta": "2024630088",
        "curp": "ABCD123456EFGHIJ88",
        "nombre_es": "CUAUHTEMOC",
        "apePater_es": "FERNANDEZ",
        "apeMater_es": "VILLAR",
        "carrera": "ISC",
        "correo": "cuauhtemoc0088@example.com",
        "contraseña": "lMoonejd"
    },
    {
        "numBoleta": "2024630089",
        "curp": "ABCD123456EFGHIJ89",
        "nombre_es": "CARLOS ANTONIO",
        "apePater_es": "DIAZ",
        "apeMater_es": "SOTO",
        "carrera": "ISC",
        "correo": "carlos_antonio0089@example.com",
        "contraseña": "n2jmzQha"
    },
    {
        "numBoleta": "2024630090",
        "curp": "ABCD123456EFGHIJ90",
        "nombre_es": "KEVIN",
        "apePater_es": "DIAZ",
        "apeMater_es": "FUENTES",
        "carrera": "ISC",
        "correo": "kevin0090@example.com",
        "contraseña": "I3PgUgxI"
    },
    {
        "numBoleta": "2024630091",
        "curp": "ABCD123456EFGHIJ91",
        "nombre_es": "RODRIGO",
        "apePater_es": "FLORES",
        "apeMater_es": "ESTOPIER",
        "carrera": "ISC",
        "correo": "rodrigo0091@example.com",
        "contraseña": "xce1sK8H"
    },
    {
        "numBoleta": "2024630092",
        "curp": "ABCD123456EFGHIJ92",
        "nombre_es": "FERNANDA",
        "apePater_es": "GARCIA",
        "apeMater_es": "JIMENEZ",
        "carrera": "ISC",
        "correo": "fernanda0092@example.com",
        "contraseña": "YPIRQBDh"
    },
    {
        "numBoleta": "2024630093",
        "curp": "ABCD123456EFGHIJ93",
        "nombre_es": "NOE RAMSES",
        "apePater_es": "GONZALEZ",
        "apeMater_es": "LLAMOSAS",
        "carrera": "ISC",
        "correo": "noe_ramses0093@example.com",
        "contraseña": "FQl1vg5V"
    },
    {
        "numBoleta": "2024630094",
        "curp": "ABCD123456EFGHIJ94",
        "nombre_es": "LUZ MIREYA",
        "apePater_es": "GARCIA",
        "apeMater_es": "GARCIA",
        "carrera": "ISC",
        "correo": "luz_mireya0094@example.com",
        "contraseña": "xDs4a3QQ"
    },
    {
        "numBoleta": "2024630095",
        "curp": "ABCD123456EFGHIJ95",
        "nombre_es": "ROGELIO ASAHID",
        "apePater_es": "GOMEZ",
        "apeMater_es": "JASSO",
        "carrera": "ISC",
        "correo": "rogelio_asahid0095@example.com",
        "contraseña": "sHuRgAfz"
    },
    {
        "numBoleta": "2024630096",
        "curp": "ABCD123456EFGHIJ96",
        "nombre_es": "LUIS RAUL",
        "apePater_es": "GARCIA",
        "apeMater_es": "BAUTISTA",
        "carrera": "ISC",
        "correo": "luis_raul0096@example.com",
        "contraseña": "59SuRc6v"
    },
    {
        "numBoleta": "2024630097",
        "curp": "ABCD123456EFGHIJ97",
        "nombre_es": "ARMANDO",
        "apePater_es": "GUZMAN",
        "apeMater_es": "BALLESTEROS",
        "carrera": "ISC",
        "correo": "armando0097@example.com",
        "contraseña": "4XoBGT3O"
    },
    {
        "numBoleta": "2024630098",
        "curp": "ABCD123456EFGHIJ98",
        "nombre_es": "OSCAR ALEXIS",
        "apePater_es": "GONZALEZ",
        "apeMater_es": "CARRETO",
        "carrera": "ISC",
        "correo": "oscar_alexis0098@example.com",
        "contraseña": "0ZnDoHSS"
    },
    {
        "numBoleta": "2024630099",
        "curp": "ABCD123456EFGHIJ99",
        "nombre_es": "DIEGO",
        "apePater_es": "GARCIA",
        "apeMater_es": "CERON",
        "carrera": "ISC",
        "correo": "diego0099@example.com",
        "contraseña": "1bW8QPoL"
    },
    {
        "numBoleta": "2024630100",
        "curp": "ABCD123456EFGHIJ00",
        "nombre_es": "ERICK",
        "apePater_es": "LARA",
        "apeMater_es": "SARMIENTO",
        "carrera": "ISC",
        "correo": "erick0100@example.com",
        "contraseña": "G0utGN7e"
    }
  ];

  // Referencia a la colección en Firestore
  final collection = FirebaseFirestore.instance.collection('alumnos');

  // Inserta cada directivo como un documento
  for (var alumno in alumnos) {
    await collection.add(alumno); // Crea un documento con ID automático
  }

  print('Datos insertados exitosamente.');
}

*/

/*

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> insertDatos() async {
  // Lista de directivos como mapas
  final List<Map<String, dynamic>> carreras = [
    {
      "id": "ISC",
      "description": "Ingeniería en Sistemas Computacionales se enfoca en el desarrollo de software, redes y soluciones tecnológicas avanzadas.",
      "mapLink": "URL_DEL_PDF_ISC",
      "objetivo": "Formar ingenieros en sistemas computacionales...",
      "perfilIngreso": "Conocimientos en matemáticas, física e informática.",
      "perfilEgreso": "El egresado podrá desempeñarse en equipos multidisciplinarios...",
      "campoLaboral": "Amplio campo en sectores público y privado..."
    },
    {
      "id": "IA",
      "description": "Inteligencia Artificial estudia y desarrolla sistemas que simulan inteligencia humana en máquinas.",
      "mapLink": "URL_DEL_PDF_IA",
      "objetivo": "Formar expertos capaces de desarrollar sistemas inteligentes...",
      "perfilIngreso": "Habilidades básicas que garanticen desempeño adecuado.",
      "perfilEgreso": "El egresado podrá trabajar en áreas como aprendizaje de máquina...",
      "campoLaboral": "Desempeño en medicina personalizada, ciudades inteligentes..."
    },
    {
      "id": "LCD",
      "description": "La Licenciatura en Ciencias de Datos se centra en el análisis y manejo de datos para la toma de decisiones informadas.",
      "mapLink": "URL_DEL_PDF_LCD",
      "objetivo": "Formar expertos capaces de extraer conocimiento implícito...",
      "perfilIngreso": "Conocimientos básicos en matemáticas y estadística.",
      "perfilEgreso": "Capacitado para tomar decisiones basadas en datos.",
      "campoLaboral": "Sectores público y privado, innovación, consultorías..."
    },
  ];

  // Referencia a la colección en Firestore
  final collection = FirebaseFirestore.instance.collection('carreras');

  // Inserta cada directivo como un documento
  for (var carrera in carreras) {
    await collection.add(carrera); // Crea un documento con ID automático
  }

  print('Datos insertados exitosamente.');
}

*/

/*

Future<void> insertDirectivos() async {
  // Lista de directivos como mapas
  final List<Map<String, dynamic>> directivos = [
    {
      "nombre_dir": "M. EN C. ANDRÉS ORTIGOZA CAMPOS",
      "depto_direc": "Dirección",
      "correo_direc": "direccion_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 46188"
    },
    {
      "nombre_dir": "M. EN C. IGNACIO RÍOS DE LA TORRE",
      "depto_direc": "Decanato",
      "correo_direc": "",
      "telefono_direc": "57296000 Ext. 52024"
    },
    {
      "nombre_dir": "M. EN P. LAURA LAZCANO XOXOTLA",
      "depto_direc": "Coordinación de Enlace y Gestión Técnica",
      "correo_direc": "enlace_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52013"
    },
    {
      "nombre_dir": "M. EN D.T.I. RICARDO ÁNGEL AGUILAR PÉREZ",
      "depto_direc": "Unidad de Informática",
      "correo_direc": "udi_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52015"
    },
    {
      "nombre_dir": "M. EN C. IVÁN GIOVANNY MOSSO GARCÍA",
      "depto_direc": "Subdirección Académica",
      "correo_direc": "sub_academica_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52023"
    },
    {
      "nombre_dir": "M. EN A.P. MARÍA DEL ROSARIO GALEANA CHÁVEZ",
      "depto_direc": "Depto. de Ciencias e Ingeniería de la Computación",
      "correo_direc": "cic_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52067"
    },
    {
      "nombre_dir": "DRA. DENI DEL CARMEN BECERRIL ELIAS",
      "depto_direc": "Depto. de Ingeniería en Sistemas Computacionales",
      "correo_direc": "escom_disc@ipn.mx",
      "telefono_direc": "57296000 Ext. 52072"
    },
    {
      "nombre_dir": "DRA. CLAUDIA CELIA DÍAZ HUERTA",
      "depto_direc": "Depto. de Innovación Educativa",
      "correo_direc": "innova.escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52044"
    },
    {
      "nombre_dir": "LIC. DIANA GABRIELA HORCASITAS DOMÍNGUEZ",
      "depto_direc": "Depto. de Evaluación y Seguimiento Académico",
      "correo_direc": "es_academico_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52021"
    },
    {
      "nombre_dir": "M. EN ADM. DE N. MARÍA MAGDALENA SALDIVAR ALMOREJO",
      "depto_direc": "Depto. de Formación Integral e Institucional",
      "correo_direc": "fii_escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52020"
    },
    {
      "nombre_dir": "M. EN C. ELIZABETH MORENO GALVÁN",
      "depto_direc": "Unidad de Tecnología Educativa y Campus Virtual",
      "correo_direc": "uteycv.escom@ipn.mx",
      "telefono_direc": "57296000 Ext. 52011"
    }
  ];

  // Referencia a la colección en Firestore
  final collection = FirebaseFirestore.instance.collection('directivos');

  // Inserta cada directivo como un documento
  for (var directivo in directivos) {
    await collection.add(directivo); // Crea un documento con ID automático
  }

  print('Datos insertados exitosamente.');
}

*/

