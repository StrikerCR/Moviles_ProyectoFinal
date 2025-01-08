import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';
import 'package:proyecto_final_fbdp_crr/baseDatos/database_connection.dart';

class AccountPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Datos del usuario autenticado
  final VoidCallback onLogout; // Callback para cerrar sesión

  AccountPage({required this.userData, required this.onLogout});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEditing = false; // Estado para habilitar o deshabilitar edición
  bool isPasswordVisible = false; // Control de visibilidad de la contraseña

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los datos del usuario
    nombreController.text = widget.userData['nombre_es'];
    correoController.text = widget.userData['correo'];
    passwordController.text = widget.userData['contraseña'];
  }

  Future<void> updateUser() async {
    try {
      final db = await DBConnection().database;

      await db.update(
        'alumno',
        {
          'nombre_es': nombreController.text.trim(),
          'correo': correoController.text.trim(),
          'contraseña': passwordController.text.trim(),
        },
        where: 'noBoleta = ?',
        whereArgs: [widget.userData['noBoleta']],
      );

      setState(() {
        isEditing = false; // Desactiva el modo de edición
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos actualizados exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar datos: $e')),
      );
    }
  }

  InputDecoration customInputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.currentTheme.primaryColor,
        title: Text(
          'Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: customInputDecoration(
                        themeProvider.currentTheme,
                        'Nombre',
                      ),
                      enabled: isEditing,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: correoController,
                      decoration: customInputDecoration(
                        themeProvider.currentTheme,
                        'Correo',
                      ),
                      enabled: isEditing,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: customInputDecoration(
                        themeProvider.currentTheme,
                        'Contraseña',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: themeProvider.currentTheme.primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      enabled: isEditing,
                    ),
                    SizedBox(height: 24),
                    if (isEditing) ...[
                      ElevatedButton(
                        onPressed: updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              themeProvider.currentTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            50,
                          ),
                        ),
                        child: Text(
                          'Guardar Cambios',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            50,
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              themeProvider.currentTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width * 0.4,
                            50,
                          ),
                        ),
                        child: Text(
                          'Editar Datos',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onLogout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.4,
                  50,
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
