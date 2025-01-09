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

