import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final bool isAuthenticated;
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.isAuthenticated,
    this.userData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ESCOM')),
        actions: [
          IconButton(
            icon: Icon(isAuthenticated ? Icons.logout : Icons.account_circle),
            onPressed: () {
              if (isAuthenticated) {
                Navigator.pushNamed(
                  context,
                  '/account',
                  arguments: userData,
                );
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                isAuthenticated
                    ? 'Hola, ${userData?['nombre_es'] ?? 'Usuario'}'
                    : 'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Directorio'),
              onTap: () {
                Navigator.pushNamed(context, '/directory');
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Ubicación'),
              onTap: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
            if (isAuthenticated) ...[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profesores'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/professors',
                    arguments: userData, // Pasar datos del usuario a la página de Profesores
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar Sesión'),
                onTap: () {
                  onLogout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false); // Vuelve al Home sin sesión
                },
              ),
            ],
          ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/imgs/escom_navidad.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Escuela Superior de Cómputo (ESCOM)',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'La Escuela Superior de Cómputo es reconocida por su excelencia académica y su formación en las áreas de computación e informática.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/career', arguments: 'ISC');
                                },
                                child: Text('ISC'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/career', arguments: 'IA');
                                },
                                child: Text('IA'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/career', arguments: 'LCD');
                                },
                                child: Text('LCD'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
