import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    void handleLogout() {
      themeProvider.changeTheme('Azul'); // Restablece el tema a Azul
      onLogout();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.currentTheme.primaryColor,
                  themeProvider.currentTheme.primaryColor.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                      Text(
                        'ESCOM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isAuthenticated ? Icons.logout : Icons.account_circle,
                          color: Colors.white,
                        ),
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
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Imagen principal
                      Container(
                        height: 200,
                        width: 320,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/imgs/escom_navidad.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Texto principal
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    24.0),
                            child: Text(
                              'Escuela Superior de Cómputo (ESCOM) \n',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    24.0),
                            child: Text(
                              'La Escuela Superior de Cómputo es reconocida por su excelencia académica y su formación en las áreas de computación e informática. \n \n Fue fundada el 13 de agosto de 1993 y ofrece las carreras de ISC, IIA y LCD.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      // Botones de carreras
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/career',
                                  arguments: 'ISC');
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(
                                MediaQuery.of(context).size.width *
                                    0.25, // Ajusta el ancho
                                50, // Altura de los botones
                              ),
                              side: BorderSide(color: Colors.white),
                              backgroundColor:
                                  themeProvider.currentTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'ISC',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/career',
                                  arguments: 'IA');
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(
                                MediaQuery.of(context).size.width *
                                    0.25, // Ajusta el ancho
                                50, // Altura de los botones
                              ),
                              side: BorderSide(color: Colors.white),
                              backgroundColor:
                                  themeProvider.currentTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'IA',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/career',
                                  arguments: 'LCD');
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(
                                MediaQuery.of(context).size.width *
                                    0.25, // Ajusta el ancho
                                50, // Altura de los botones
                              ),
                              side: BorderSide(color: Colors.white),
                              backgroundColor:
                                  themeProvider.currentTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'LCD',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Menú lateral
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeProvider.currentTheme.primaryColor,
              ),
              child: Center(
                child: Text(
                  isAuthenticated
                      ? 'Hola, ${userData?['nombre_es'] ?? 'Usuario'}'
                      : 'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.contacts,
                          color: themeProvider.currentTheme.primaryColor),
                      title: Text('Directorio',
                          style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor)),
                      onTap: () {
                        Navigator.pushNamed(context, '/directory');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.map,
                          color: themeProvider.currentTheme.primaryColor),
                      title: Text('Ubicación',
                          style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor)),
                      onTap: () {
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                    if (isAuthenticated) ...[
                      ListTile(
                        leading: Icon(Icons.person,
                            color: themeProvider.currentTheme.primaryColor),
                        title: Text('Profesores',
                            style: TextStyle(
                                color:
                                    themeProvider.currentTheme.primaryColor)),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/professors',
                            arguments: userData,
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.color_lens,
                            color: themeProvider.currentTheme.primaryColor),
                        title: Text('Ajustes',
                            style: TextStyle(
                                color:
                                    themeProvider.currentTheme.primaryColor)),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout,
                            color: themeProvider.currentTheme.primaryColor),
                        title: Text('Cerrar Sesión',
                            style: TextStyle(
                                color:
                                    themeProvider.currentTheme.primaryColor)),
                        onTap: handleLogout,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
