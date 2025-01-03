import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
            ),
            SizedBox(height: 16),
            TextField(
              controller: correoController,
              decoration: InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
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
              enabled: isEditing,
            ),
            SizedBox(height: 24),
            if (isEditing) ...[
              ElevatedButton(
                onPressed: updateUser,
                child: Text('Guardar Cambios'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                  });
                },
                child: Text('Cancelar'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                child: Text('Editar Datos'),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onLogout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ); // Redirige al HomePage sin sesión
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Fondo rojo
                foregroundColor: Colors.white, // Texto blanco
              ),
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
