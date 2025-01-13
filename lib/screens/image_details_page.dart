import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:provider/provider.dart';
import 'package:proyecto_final_fbdp_crr/theme/theme_provider.dart';

class ImageDetailsPage extends StatefulWidget {
  final String imageId;
  final String imageUrl;

  const ImageDetailsPage({
    required this.imageId,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  _ImageDetailsPageState createState() => _ImageDetailsPageState();
}

class _ImageDetailsPageState extends State<ImageDetailsPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(String comment) async {
    if (comment.isNotEmpty) {
      final docRef = FirebaseFirestore.instance
          .collection('imageComments')
          .doc(widget.imageId)
          .collection('comments')
          .doc();

      await docRef.set({
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Sin fecha';
    final date = timestamp.toDate();
    return DateFormat('d MMMM yyyy, HH:mm', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.currentTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Comentarios de la Imagen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado al tocar fuera
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Imagen con formato
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.infinity,
                          semanticLabel: 'Imagen subida por el usuario',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto para añadir comentarios
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Añadir un comentario...',
                              filled: true,
                              fillColor: primaryColor.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _addComment(_commentController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Lista de comentarios
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('imageComments')
                          .doc(widget.imageId)
                          .collection('comments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay comentarios aún.',
                              style: TextStyle(color: primaryColor),
                            ),
                          );
                        }

                        final comments = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index].data()
                                as Map<String, dynamic>; // Obtener datos del comentario

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: Text(
                                  comment['text'] ?? '',
                                  style: TextStyle(color: primaryColor),
                                ),
                                subtitle: Text(
                                  comment['timestamp'] != null
                                      ? DateFormat('dd MMM yyyy, hh:mm a').format(
                                          (comment['timestamp'] as Timestamp)
                                              .toDate(),
                                        )
                                      : 'Sin fecha',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
