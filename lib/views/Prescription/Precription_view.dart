import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/views/Prescription/ImageViewScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../View_view_Model/PrecripProvider.dart'; // Check your path
import '../../utiles/Utiles.dart'; // Check your path

class PrecriptionView extends StatefulWidget {
  const PrecriptionView({super.key});

  @override
  State<PrecriptionView> createState() => _PrecriptionViewState();
}

class _PrecriptionViewState extends State<PrecriptionView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrecripProvider>(context, listen: false).showFiles(context);
    });
  }


  // Moved logic out of build method
  Future<void> _startUpload() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final provider = Provider.of<PrecripProvider>(context, listen: false);
    File? image = provider.image;

    if (image == null) return;

    provider.setLoading(true);

    try {
      // 1. Create Unique Filename (Timestamp to avoid collision)
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}";
      final String filePath = '$uid/receipts/$fileName';

      // 2. Upload to Supabase
      await supabase.storage.from('preciptionorrecipt').upload(filePath, image);

      if (mounted) {
        Utiles().toastMessage('Upload Successful!');
        provider.showFiles(context);
        provider.clearImage();
      }
    } on StorageException catch (e) {
      Utiles().toastMessage("Storage Error: ${e.message}");
    } catch (e) {
      Utiles().toastMessage("Upload failed: ${e.toString()}");
    } finally {
      provider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrecripProvider>(builder: (context, value, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Prescriptions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          elevation: 0,
          actions: [
            if (value.image != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => value.clearImage(),
                tooltip: "Cancel Selection",
              )
          ],
        ),

        //If image is selected, show Preview. Else, show Files List.
        body: value.image != null
            ? _buildUploadPreview(value)
            : _buildFilesList(value),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: value.selectedIndex,
          onTap: value.onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_copy_outlined),
              label: "My Files",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              label: "Camera",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_rounded),
              label: "Gallery",
            ),
          ],
        ),
      );
    });
  }

  // WIDGET 1: Upload Preview Screen (Modern Look)

  Widget _buildUploadPreview(PrecripProvider value) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
// Image Card
            Container(
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
                image: DecorationImage(
                  image: FileImage(value.image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
// Upload Button
            value.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton.icon(
              onPressed: _startUpload,
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
              label: const Text("Upload Now", style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // WIDGET 2: Files Grid List (Completed)
  Widget _buildFilesList(PrecripProvider provider) {
    final String? uid = FirebaseAuth.instance.currentUser!.uid;
    // 1. Show Loading
    if (provider.isLoading && provider.allFiles.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    // ✅ FIX: Filter lagayen taake '.emptyFolderPlaceholder' gayab ho jaye
    final validFiles = provider.allFiles
        .where((file) => file.name != '.emptyFolderPlaceholder')
        .toList();

    // 2. Show Empty State (Agar filter ke baad list khali bache)
    if (validFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.snippet_folder_rounded, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Prescriptions Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text("Use Camera or Gallery to add files", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 3. Show GridView
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: validFiles.length, //  Ab hum filtered list ki length use karenge
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final file = validFiles[index]; // Ab hum filtered list se file uthayenge

          // Construct Public URL
          final imageUrl = Supabase.instance.client.storage
              .from('preciptionorrecipt')
              .getPublicUrl('$uid/receipts/${file.name}');

          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageViewScreen(imageUrl: imageUrl, fileName: file.name) ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(color: Colors.green)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.red));
                        },
                      ),
                    ),
                  ),
                  // File Name
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}