import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class CareerPage extends StatelessWidget {
  const CareerPage({super.key});


Future<bool> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    return true;
  } else {
    openAppSettings(); // Abre los ajustes si el usuario deniega los permisos
    return false;
  }
}


  Future<void> downloadPdf(
      BuildContext context, String fileName, String assetPath) async {
    try {
      // Verificar y solicitar permisos
      if (await requestStoragePermission()) {
        // Crear o verificar la carpeta Documents
        final directory = Directory('/storage/emulated/0/Documents');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Verificar si el archivo ya existe y eliminarlo
        if (await file.exists()) {
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Archivo existente eliminado: $filePath'),
            ),
          );
        }

        // Simular una descarga desde el archivo de activos
        final bytes = await rootBundle.load(assetPath);
        await file.writeAsBytes(bytes.buffer.asUint8List());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo descargado en: $filePath'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de almacenamiento denegado.'),
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

    String description;
    String mapLink;
    String objetivo;
    String perfilIngreso;
    String perfilEgreso;
    String campoLaboral;
    String carrera = 'ISC';

    switch (career) {
      case 'ISC':
        carrera = 'ISC';
        description =
            'Ingeniería en Sistemas Computacionales se enfoca en el desarrollo de software, redes y soluciones tecnológicas avanzadas.';
        mapLink = 'assets/pdf/mapaCurricularISC2020.pdf';

        objetivo =
            'Formar ingenieros en sistemas computacionales de sólida preparación científica y tecnológica en los ámbitos del desarrollo de software y hardware, que propongan, analicen, diseñen, desarrollen, implementen y gestionen sistemas computacionales a partir de tecnologías de vanguardia y metodologías, normas y estándares nacionales e internacionales de calidad; líderes de equipos de trabajo multidisciplinarios y multiculturales, con un alto sentido ético y de responsabilidad.';
        perfilIngreso =
            'Los aspirantes a estudiar este programa deberán tener conocimientos en matemáticas, física e informática. Es también conveniente que posean conocimientos de inglés. Así mismo, deberán contar con habilidades como análisis y síntesis de información, razonamiento lógico y expresión oral y escrita. Así como actitudes de respeto y responsabilidad.';
        perfilEgreso =
            'El egresado del programa académico de Ingeniería en Sistemas Computacionales podrá desempeñarse en equipos multidisciplinarios e interdisciplinarios en los ámbitos del desarrollo de software y hardware, sustentando su actuación profesional en valores éticos y de responsabilidad social, con un enfoque de liderazgo y sostenibilidad en los sectores público y privado.';
        campoLaboral =
            'El campo profesional en el que se desarrollan los egresados de este Programa Académico es muy amplio, se localiza en los sectores público y privado; en consultorías, en empresas del sector financiero, comercial, de servicios o bien en aquellas dedicadas a la innovación, en entidades federales, estatales, así como pequeño empresario creando empresas emergentes (startups).';
        break;
      case 'IA':
        carrera = 'IA';
        description =
            'Inteligencia Artificial estudia y desarrolla sistemas que simulan inteligencia humana en máquinas.';
        mapLink = 'assets/pdf/mapaCurricularIIA2020.pdf';
        objetivo =
            'Formar expertos capaces de desarrollar sistemas inteligentes utilizando diferentes metodologías en las diferentes etapas de desarrollo y aplicando algoritmos en áreas como aprendizaje de máquina, procesamiento automático de lenguaje natural, visión artificial y modelos bioinspirados para atender las necesidades de los diferentes sectores de la sociedad a través de la generación de procesos y soluciones innovadoras.';
        perfilIngreso =
            'Los estudiantes que ingresen al Instituto Politécnico Nacional, en cualquiera de sus programas y niveles, deberán contar con los conocimientos y las habilidades básicas que garanticen un adecuado desempeño en el nivel al que solicitan su ingreso. Asimismo, deberán contar con las actitudes y valores necesarios para responsabilizarse de su proceso formativo y asumir una posición activa frente al estudio y al desarrollo de los proyectos y trabajos requeridos, coincidentes con el ideario y principios del IPN.';
        perfilEgreso =
            'El egresado de la Ingeniería en Inteligencia Artificial se desempeñará colaborativamente en equipos multidisciplinarios en el análisis, diseño, implementación, validación, implantación, supervisión y gestión de sistemas inteligentes, aplicando algoritmos en áreas como aprendizaje de máquina, procesamiento automático de lenguaje natural, visión artificial y modelos bioinspirados; ejerciendo su profesión con liderazgo, ética y responsabilidad social.';
        campoLaboral =
            'Este profesional podrá desempeñarse en el desarrollo y aplicación de la Inteligencia Artificial, en los ámbitos público y privado, en campos ocupacionales como los que se enlistan a continuación:\n\n'
            'MEDICINA PERSONALIZADA: Procesos en el ámbito médico tales como el pre diagnóstico, análisis de imágenes médicas, análisis de historiales clínicos.\n'
            'ASISTENCIA Y MOVILIDAD PARA PERSONAS CON DISCAPACIDAD O DE LA TERCERA EDAD: Recursos que faciliten la movilidad y el acceso a servicios a través de diferentes medios, como: sillas de ruedas autónomas, guías inteligentes, traductores automáticos, generadores de texto, software de terapia y de acompañamiento.\n'
            'CIUDADES INTELIGENTES Y SOSTENIBLES: Sistemas inteligentes para mejorar la calidad de vida aplicados al transporte autónomo, identificación biométrica, detección de fraude, prevención y detección de accidentes, tutores inteligentes, control de tráfico vehicular, monitoreo y alertamiento ambiental, protección civil.';
        break;
      case 'LCD':
        carrera = 'LCD';
        description =
            'La Licenciatura en Ciencias de Datos se centra en el análisis y manejo de datos para la toma de decisiones informadas.';
        mapLink = 'assets/pdf/mapaCurricularLCD2020H.pdf';
        objetivo =
            'Formar expertos capaces de extraer conocimiento implícito y complejo, potencialmente útil a partir de grandes conjuntos de datos, utilizando métodos de inteligencia artificial, aprendizaje de máquina, estadística, sistemas de bases de datos y modelos matemáticos sobre comportamientos probables, para apoyar la toma de decisiones de alta dirección.';
        perfilIngreso =
            'Los estudiantes que ingresen al Instituto Politécnico Nacional, en cualquiera de sus programas y niveles, deberán contar con los conocimientos y las habilidades básicas que garanticen un adecuado desempeño en el nivel al que solicitan su ingreso. Asimismo, deberán contar con las actitudes y valores necesarios para responsabilizarse de su proceso formativo y asumir una posición activa frente al estudio y al desarrollo de los proyectos y trabajos requeridos, coincidentes con el ideario y principios del IPN.';
        perfilEgreso =
            'El egresado de la Licenciatura en Ciencias de Datos será capaz de extraer conocimiento implícito y complejo, potencialmente útil (descubrimiento de patrones, desviaciones, anomalías, valores anómalos, situaciones interesantes, tendencias), a partir de grandes conjuntos de datos. Utiliza los métodos de la inteligencia artificial, aprendizaje de máquina, estadística y sistemas de bases de datos para la toma de decisiones de alta dirección, fundadas en los datos y modelos matemáticos sobre comportamientos probables, deseables e indeseables, participando en dinámicas de trabajo colaborativo e interdisciplinario con sentido ético y responsabilidad social.';
        campoLaboral =
            'El campo profesional en el que se desarrollan los egresados de este Programa Académico es muy amplio, se localiza en los sectores público y privado; en consultorías, en empresas del sector financiero, comercial, de servicios o bien en aquellas dedicadas a la innovación, en entidades federales, estatales, así como pequeño empresario creando empresas emergentes (startups).';
        break;
      default:
        description = 'Información no disponible para esta carrera.';
        mapLink = '';
        objetivo =
            perfilIngreso = perfilEgreso = campoLaboral = 'No disponible.';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        title: Text(
          career,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: themeProvider.currentTheme.primaryColor,),
              
            ),
            const SizedBox(height: 8),
            Text(objetivo, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Perfil de Ingreso:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: themeProvider.currentTheme.primaryColor,),
            ),
            const SizedBox(height: 8),
            Text(perfilIngreso, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Perfil de Egreso:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: themeProvider.currentTheme.primaryColor,),
            ),
            const SizedBox(height: 8),
            Text(perfilEgreso, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Campo Laboral:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: themeProvider.currentTheme.primaryColor,),
            ),
            const SizedBox(height: 8),
            Text(campoLaboral, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await downloadPdf(context, 'MapaCurricular$carrera.pdf', mapLink);
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
      ),
    );
  }
}