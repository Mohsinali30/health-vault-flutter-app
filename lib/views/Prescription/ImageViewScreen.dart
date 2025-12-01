import 'package:flutter/material.dart';
import 'package:gal/gal.dart'; // Import Gal
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../View_view_Model/PrecripProvider.dart';
import '../../utiles/Utiles.dart';

class ImageViewScreen extends StatefulWidget {
  final String imageUrl;
  final String fileName;
  final String uid;

  const ImageViewScreen({
    super.key,
    required this.imageUrl,
    required this.fileName,
    required this.uid,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool isActionLoading = false;

  //  1. DOWNLOAD FUNCTION (FIXED)
  Future<void> _downloadImage() async {
    setState(() => isActionLoading = true);

    try {
      // 1. Mobile ki temporary directory lein
      var appDocDir = await getTemporaryDirectory();
      String savePath = "${appDocDir.path}/${widget.fileName}";

      // 2. Download karein
      await Dio().download(widget.imageUrl, savePath);

      // 3. Gallery mein Save karein (Gal Package)
      // Note: Gal.putImage kuch return nahi karta. Agar error nahi aya, matlab success hai.
      await Gal.putImage(savePath);

      // Agar yahan tak pohanch gaye to matlab save ho gaya
      Utiles().toastMessage("Image Saved to Gallery! ");

    } on GalException catch (e) {
      // Gal ke specific errors handle karein (Access Denied etc)
      Utiles().toastMessage("Permission Error: ${e.type.message}");
    } catch (e) {
      Utiles().toastMessage("Download Error: $e");
    } finally {
      if (mounted) setState(() => isActionLoading = false);
    }
  }

  //  2. DELETE FUNCTION (Ye Theek Tha)
  Future<void> _deleteImage() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Image?"),
        content: const Text("Are you sure you want to delete this prescription?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isActionLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final String filePath = '${widget.uid}/receipts/${widget.fileName}';

      await supabase.storage.from('preciptionorrecipt').remove([filePath]);

      if (mounted) {
        Utiles().toastMessage("Deleted Successfully 🗑");
        await Provider.of<PrecripProvider>(context, listen: false).showFiles(context);
        Navigator.pop(context);
      }
    } catch (e) {
      Utiles().toastMessage("Delete Error:");
    } finally {
      if (mounted) setState(() => isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.fileName,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis
        ),
        actions: [
          if (isActionLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: "Download to Gallery",
              onPressed: _downloadImage,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: "Delete Image",
              onPressed: _deleteImage,
            ),
          ],
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.imageUrl,
            child: Image.network(
              widget.imageUrl,
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