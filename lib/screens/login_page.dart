import 'package:flutter/material.dart';
import 'package:proyecto_final_fbdp_crr/baseDatos/database_connection.dart';

class LoginPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoginSuccess;

  LoginPage({required this.onLoginSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController boletaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isPasswordVisible = false; // Estado para controlar la visibilidad de la contraseña

  Future<void> login() async {
    final boleta = boletaController.text.trim();
    final password = passwordController.text.trim();

    try {
      final db = await DBConnection().database;

      final result = await db.rawQuery(
        'SELECT * FROM alumno WHERE noBoleta = ? AND contraseña = ?',
        [boleta, password],
      );

      if (result.isNotEmpty) {
        widget.onLoginSuccess(result[0]);
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          errorMessage = 'Número de Boleta o Contraseña incorrectos.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al iniciar sesión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
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
                        controller: passwordController,
                        obscureText: !isPasswordVisible, // Controla si el texto es visible
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
                        onPressed: login,
                        child: Text('Iniciar Sesión'),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text('¿No tienes cuenta? Regístrate aquí'),
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
