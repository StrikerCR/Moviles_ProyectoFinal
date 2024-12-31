import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(19.504217, -99.146049),
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('escom'),
                        position: LatLng(19.504217, -99.146049),
                        infoWindow: InfoWindow(
                          title: 'ESCOM - IPN',
                          snippet: 'Av. Juan de Dios Bátiz, CDMX',
                        ),
                      ),
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dirección',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Av. Juan de Dios Batiz casi esquina Miguel Othón de Mendizabal.\nU.P. Adolfo López Mateos. C. P. 12345\nAlcaldía Gustavo Aa. Madero\nTeléfono: 55 5729 6000 Ext. 52001\nCorreo: escom@ipn.mx',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
