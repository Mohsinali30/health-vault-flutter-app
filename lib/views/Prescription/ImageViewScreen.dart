import 'package:flutter/material.dart';

import '../../utiles/Utiles.dart';


class ImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final String fileName;

  const ImageViewScreen({super.key, required this.imageUrl, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full screen image ke liye black background acha lagta hai
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          // Optional: Download Button logic baad mein laga sakte hain
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Utiles().toastMessage("Download feature coming soon!");
            },
          )
        ],
      ),
      body: Center(
        // InteractiveViewer: Is se user image ko Zoom In/Out kar sakega
        child: InteractiveViewer(
          panEnabled: true, // Image ko drag karna
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4, // 4x tak zoom
          child: Hero( // Hero Animation for smooth transition
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}