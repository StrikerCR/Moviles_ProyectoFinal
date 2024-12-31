import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ESCOM')),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
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
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 300, // Altura ajustada para que la imagen sea más pequeña
            width: double.infinity, // Anchura completa de la pantalla
            child: Image.asset(
              'assets/imgs/escom_navidad.jpeg',
              fit: BoxFit.contain, // Asegura que la imagen no se recorte
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Escuela Superior de Cómputo (ESCOM)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        Navigator.pushNamed(context, '/career', arguments: 'ISC');
                      },
                      child: Text('ISC'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/career', arguments: 'IA');
                      },
                      child: Text('IA'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/career', arguments: 'LCD');
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
    );
  }
}