import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/screens/image_details_page.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
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
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  List<String> imageUrls = [];
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchImages();
    _startCarousel();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref('img_escom/');
      final ListResult result = await storageRef.listAll();
      final List<String> urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()).toList(),
      );

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      _showSnackBar('Error al cargar imágenes: $e');
    }
  }

  Future<void> _uploadImage({required ImageSource source}) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        final ref = FirebaseStorage.instance
            .ref('img_escom/${DateTime.now().toIso8601String()}');
        await ref.putFile(File(image.path));

        _showSnackBar('Imagen subida exitosamente');

        _fetchImages();
      } else {
        _showSnackBar('No se seleccionó ninguna imagen.');
      }
    } catch (e) {
      _showSnackBar('Error al tomar la imagen: $e');
    }
  }

  void _showSnackBar(String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeProvider.currentTheme.primaryColor,
      ),
    );
  }

  void _showImageSourceDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.currentTheme.primaryColor,
          title: Text(
            'Selecciona la fuente de la imagen',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadImage(source: ImageSource.camera);
              },
              child: Text(
                'Cámara',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadImage(source: ImageSource.gallery);
              },
              child: Text(
                'Galería',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startCarousel() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && imageUrls.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % imageUrls.length;
        });
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startCarousel();
      }
    });
  }

  void handleLogout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUser != null
          ? FirebaseFirestore.instance
              .collection('alumnos')
              .doc(currentUser!.uid)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        userData = snapshot.data?.data() as Map<String, dynamic>?;

        return Scaffold(
          body: Stack(
            children: [
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
              SafeArea(
                child: Column(
                  children: [
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
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
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
                              currentUser != null
                                  ? Icons.logout
                                  : Icons.account_circle,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (currentUser != null) {
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
                          Container(
                            height: 250,
                            width: 350,
                            child: imageUrls.isEmpty
                                ? Center(
                                    child: Text(
                                      'Cargando imágenes...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : PageView.builder(
                                    controller: _pageController,
                                    itemCount: imageUrls.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = imageUrls[index];
                                      final imageId = 'image_$index';

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageDetailsPage(
                                                imageId: imageId,
                                                imageUrl: imageUrl,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          OutlinedButton(
                            onPressed: _showImageSourceDialog,
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.6,
                                50,
                              ),
                              side: BorderSide(color: Colors.white),
                              backgroundColor:
                                  themeProvider.currentTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Sube un recuerdo de ESCOM',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24.0),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24.0),
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
                                    MediaQuery.of(context).size.width * 0.25,
                                    50,
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
                                    MediaQuery.of(context).size.width * 0.25,
                                    50,
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
                                    MediaQuery.of(context).size.width * 0.25,
                                    50,
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
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: themeProvider.currentTheme.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      currentUser != null
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
                        if (currentUser != null) ...[
                          ListTile(
                            leading: Icon(Icons.person,
                                color: themeProvider.currentTheme.primaryColor),
                            title: Text('Profesores',
                                style: TextStyle(
                                    color: themeProvider.currentTheme.primaryColor)),
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
                                    color: themeProvider.currentTheme.primaryColor)),
                            onTap: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout,
                                color: themeProvider.currentTheme.primaryColor),
                            title: Text('Cerrar Sesión',
                                style: TextStyle(
                                    color: themeProvider.currentTheme.primaryColor)),
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
      },
    );
  }
}
