import 'package:flutter/material.dart';
import 'package:proyecto_final_fbdp_crr/baseDatos/database_connection.dart';
import 'package:sqflite/sqflite.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController boletaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  String errorMessage = '';
  bool isPasswordVisible = false; // Estado para controlar la visibilidad de la contraseña

  Future<void> register() async {
    final boleta = boletaController.text.trim();
    final nombre = nombreController.text.trim();
    final password = passwordController.text.trim();
    final correo = correoController.text.trim();

    try {
      final db = await DBConnection().database;

      await db.insert(
        'alumno',
        {
          'noBoleta': boleta,
          'nombre_es': nombre,
          'contraseña': password,
          'correo': correo,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Navigator.pop(context); // Regresa a la página de inicio de sesión
    } catch (e) {
      setState(() {
        errorMessage = 'Error de registro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: isKeyboardVisible
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: boletaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Número de Boleta',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: correoController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: register,
                        child: Text('Registrarse'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
