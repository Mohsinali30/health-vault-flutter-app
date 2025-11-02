import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:firebase_practice/utiles/RecentActivityCard.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_filex/open_filex.dart';

class Viewallfiles extends StatefulWidget {

   Viewallfiles();

  @override
  State<Viewallfiles> createState() => _ViewallfilesState();
}

class _ViewallfilesState extends State<Viewallfiles> {


  final supaBaseRef = Supabase.instance.client;




  @override
  Widget build(BuildContext context) {
    final provider= Provider.of<Loadingstate>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Medical Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

      ),
      body: Consumer<Loadingstate>(
        builder: (context, provider, child) {
          final files = provider.allFiles; // 💡 List Yahan Se Mil Jayegi 💡

          // List ki lambai (length) ko use karein
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return RecentActivityCard(icon: Icons.drive_folder_upload_outlined, title: Text(file.name ?? 'Unknown File'),
               onViewDetails:()=> DownloadAndOpen,
                buttonicon:Icons.download_for_offline_outlined ,);

            },
          );
        },
      ),
    );


  }


  Future<void> DownloadAndOpen(String filepath)async
  {        final provider= Provider.of<Loadingstate>(context,listen: false);

    provider.setloading(true);
    try{
      final tempDir= await getTemporaryDirectory();
      final localpath = "${tempDir.path}/${filepath.split('/').last}";
      final localFile =File(localpath);
      final fileData = await supaBaseRef.storage.from("files").download(filepath);
      await localFile.writeAsBytes(fileData);
      await OpenFilex.open(localpath);

    }catch(e){
      Utiles().toastMessage(e.toString());
      provider.setloading(false);
    }
  }
  }


