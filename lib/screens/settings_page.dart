import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona un tema:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 0, 93, 139)),
              title: Text('Azul'),
              onTap: () => themeProvider.changeTheme('Azul'),
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.deepPurple),
              title: Text('Morado'),
              onTap: () => themeProvider.changeTheme('Morado'),
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 128, 0, 64)),
              title: Text('Guinda'),
              onTap: () => themeProvider.changeTheme('Guinda'),
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange),
              title: Text('Naranja'),
              onTap: () => themeProvider.changeTheme('Naranja'),
            ),
          ],
        ),
      ),
    );
  }
}
