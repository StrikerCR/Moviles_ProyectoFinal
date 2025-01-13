import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController boletaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apePaternoController = TextEditingController();
  final TextEditingController apeMaternoController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController curpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      // Si no pasa las validaciones, no continuar
      return;
    }

    final boleta = boletaController.text.trim();
    final nombre = nombreController.text.trim();
    final apePaterno = apePaternoController.text.trim();
    final apeMaterno = apeMaternoController.text.trim();
    final carrera = carreraController.text.trim();
    final curp = curpController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Registrar usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar información adicional en la colección `alumnos`
      final userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('alumnos').doc(userId).set({
        'numBoleta': boleta,
        'nombre_es': nombre,
        'apePater_es': apePaterno,
        'apeMater_es': apeMaterno,
        'carrera': carrera,
        'curp': curp,
        'correo': email,
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'Error de registro: ${e.toString()}';
      });
    }
  }

  String? validateBoleta(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de boleta es obligatorio.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'El número de boleta debe tener 10 dígitos.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'El correo no tiene un formato válido.';
    }
    return null;
  }

  String? validateCURP(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CURP es obligatorio.';
    }
    if (!RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}\d{2}$').hasMatch(value)) {
      return 'El CURP no tiene un formato válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d.*\d)(?=.*[a-z])(?=.*[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres, incluir 1 mayúscula, 2 números, 1 carácter especial y letras minúsculas.';
    }
    return null;
  }

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 93, 139)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 0, 93, 139),
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 0, 93, 139),
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 0, 93, 139),
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
        backgroundColor: const Color.fromARGB(255, 0, 93, 139),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: isKeyboardVisible
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: boletaController,
                          keyboardType: TextInputType.number,
                          decoration: customInputDecoration('Número de Boleta'),
                          validator: validateBoleta,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: nombreController,
                          decoration: customInputDecoration('Nombre'),
                          validator: (value) =>
                              value!.isEmpty ? 'El nombre es obligatorio.' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: apePaternoController,
                          decoration: customInputDecoration('Apellido Paterno'),
                          validator: (value) => value!.isEmpty
                              ? 'El apellido paterno es obligatorio.'
                              : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: apeMaternoController,
                          decoration: customInputDecoration('Apellido Materno'),
                          validator: (value) => value!.isEmpty
                              ? 'El apellido materno es obligatorio.'
                              : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: carreraController,
                          decoration: customInputDecoration('Carrera'),
                          validator: (value) =>
                              value!.isEmpty ? 'La carrera es obligatoria.' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: curpController,
                          decoration: customInputDecoration('CURP'),
                          validator: validateCURP,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: customInputDecoration('Correo Electrónico'),
                          validator: validateEmail,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration:
                              customInputDecoration('Contraseña').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromARGB(255, 0, 93, 139),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: validatePassword,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 93, 139),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.4,
                              50,
                            ),
                          ),
                          child: Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
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
