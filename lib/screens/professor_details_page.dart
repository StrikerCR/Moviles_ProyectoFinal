import 'package:flutter/material.dart';

class ProfessorDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> professor =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Profesor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text(
              professor['name']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              professor['department']!,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 8),
                Text(professor['email']!),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 8),
                Text(professor['location']!),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule),
                SizedBox(width: 8),
                Text(professor['schedule']!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
