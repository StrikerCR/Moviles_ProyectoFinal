import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class AccountPage extends StatefulWidget {
  final Map<String, dynamic> userData; // User's authenticated data
  final VoidCallback onLogout; // Callback for logout

  AccountPage({required this.userData, required this.onLogout});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apePaternoController = TextEditingController();
  final TextEditingController apeMaternoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEditing = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.userData['nombre_es'] ?? '';
    apePaternoController.text = widget.userData['apePater_es'] ?? '';
    apeMaternoController.text = widget.userData['apeMater_es'] ?? '';
    passwordController.text = widget.userData['contraseña'] ?? '';
  }

  Future<void> updateUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No se pudo obtener el usuario actual.");
      }

      final uid = user.uid; // Obtener el UID del usuario autenticado

      // Actualizar los datos en Firestore
      await FirebaseFirestore.instance.collection('alumnos').doc(uid).update({
        'nombre_es': nombreController.text.trim(),
        'apePater_es': apePaternoController.text.trim(),
        'apeMater_es': apeMaternoController.text.trim(),
        'contraseña': passwordController.text.trim(),
      });

      setState(() {
        isEditing = false;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    controller: apePaternoController,
                    decoration: customInputDecoration(
                      themeProvider.currentTheme,
                      'Apellido Paterno',
                    ),
                    enabled: isEditing,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: apeMaternoController,
                    decoration: customInputDecoration(
                      themeProvider.currentTheme,
                      'Apellido Materno',
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
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onLogout,
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
        },
      ),
    );
  }
}
