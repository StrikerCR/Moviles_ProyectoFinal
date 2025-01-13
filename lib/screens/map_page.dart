import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _googleMapController;
  LatLng _escomPosition = LatLng(19.504217, -99.146049);
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String selectedMode = 'driving'; // Por defecto: coche
  final String _apiKey = 'AIzaSyDe3j-SoK6x632dX2sr5mcu0lYpF0tasMg';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          // Verifica si el widget está montado antes de llamar a setState
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }

        if (_currentPosition != null) {
          _getDirections(_currentPosition!, _escomPosition);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ubicación: $e')),
        );
      }
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    try {
      final String mode = selectedMode == 'transit' ? 'transit' : 'driving';

      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          if (mounted) {
            setState(() {
              _polylines.clear();
              _markers.clear();

              for (final leg in data['routes'][0]['legs']) {
                for (final step in leg['steps']) {
                  final String travelMode = step['travel_mode'];

                  if (travelMode == 'TRANSIT' &&
                      step['transit_details'] != null) {
                    final transitDetails = step['transit_details'];
                    final String vehicleType =
                        transitDetails['line']['vehicle']['type'];

                    final LatLng startLocation = LatLng(
                      step['start_location']['lat'],
                      step['start_location']['lng'],
                    );

                    final Color color = (vehicleType == 'SUBWAY')
                        ? Colors.purple
                        : (vehicleType == 'BUS' ? Colors.green : Colors.blue);

                    _polylines.add(Polyline(
                      polylineId: PolylineId('transit-${_polylines.length}'),
                      points: _decodePolyline(step['polyline']['points']),
                      color: color,
                      width: 5,
                    ));

                    _markers.add(Marker(
                      markerId: MarkerId('transit-${_markers.length}'),
                      position: startLocation,
                      infoWindow: InfoWindow(
                        title: transitDetails['line']['name'],
                        snippet:
                            '${transitDetails['line']['short_name']}, ${transitDetails['line']['vehicle']['name']}',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        vehicleType == 'SUBWAY'
                            ? BitmapDescriptor.hueViolet
                            : BitmapDescriptor.hueGreen,
                      ),
                    ));
                  } else {
                    _polylines.add(Polyline(
                      polylineId: PolylineId('other-${_polylines.length}'),
                      points: _decodePolyline(step['polyline']['points']),
                      color: travelMode == 'WALKING'
                          ? Colors.orange
                          : Colors.blue, // Caminata o coche
                      width: 5,
                    ));
                  }
                }
              }

              _markers.add(Marker(
                markerId: MarkerId('destination'),
                position: destination,
                infoWindow: InfoWindow(
                  title: 'Destino',
                  snippet: 'ESCOM - IPN',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ));
            });
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontró una ruta disponible.')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ruta.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la solicitud de ruta: $e')),
        );
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubicación',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeProvider.currentTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: themeProvider.currentTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _escomPosition,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (controller) {
                      _googleMapController = controller;
                    },
                    markers: _markers,
                    polylines: _polylines,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: themeProvider.currentTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTransportOption('Coche', Icons.directions_car,
                      themeProvider.currentTheme.primaryColor, 'driving'),
                  _buildTransportOption('Transporte', Icons.directions_transit,
                      themeProvider.currentTheme.primaryColor, 'transit'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconInfoRow(
                    Icons.location_on,
                    'Av. Juan de Dios Batiz casi esquina Miguel Othón de Mendizabal. U.P. Adolfo López Mateos. C. P. 12345',
                    themeProvider.currentTheme.primaryColor),
                _buildIconInfoRow(Icons.phone, '55 5729 6000 Ext. 52001',
                    themeProvider.currentTheme.primaryColor),
                _buildIconInfoRow(Icons.email, 'escom@ipn.mx',
                    themeProvider.currentTheme.primaryColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorLegend(Colors.blue, 'Coche'),
                _buildColorLegend(Colors.green, 'Camión'),
                _buildColorLegend(Colors.purple, 'Metro'),
                _buildColorLegend(Colors.orange, 'Caminar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportOption(
      String label, IconData icon, Color color, String mode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
          if (_currentPosition != null) {
            _getDirections(_currentPosition!, _escomPosition);
          }
        });
      },
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildIconInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildColorLegend(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 8,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
