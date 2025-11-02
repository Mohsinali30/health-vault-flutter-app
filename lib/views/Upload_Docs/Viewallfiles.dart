import 'package:firebase_practice/views/Upload_Docs/uploadScreen.dart';
import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Supabase_services/bucketoperations.dart';

class Viewallfiles extends StatefulWidget {

   Viewallfiles();

  @override
  State<Viewallfiles> createState() => _ViewallfilesState();
}

class _ViewallfilesState extends State<Viewallfiles> {
  final supaBaseRef = Supabase.instance.client;
  final UploadScreen fetch =UploadScreen();


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    final provider= Provider.of<Loadingstate>( context,listen: false);
    provider.fetchallFiles(context);

}

  @override
  Widget build(BuildContext context) {
   // final provider= Provider.of<Loadingstate>(context,listen: false);
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
              return
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: cardBackgroundColor, // Use the defined card background color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.drive_folder_upload_outlined, size: 28.0, color: primaryGreen),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(file.name ?? 'Unknown File',
                                  style:  TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed:()=>BucketOperation().DeleteFile(file.name),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen, // Button background color
                                  foregroundColor: Colors.white, // Button text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: Icon(Icons.delete_outline_outlined ,size: 25,color: Colors.white,)
                            ),
                            SizedBox(width: 13,),
                            ElevatedButton(
                                onPressed:()=> BucketOperation().DownloadAndOpen(file.name),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen, // Button background color
                                  foregroundColor: Colors.white, // Button text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: Icon(Icons.download_for_offline_outlined ,size: 25,color: Colors.white,)
                            ),

                          ],



                        ),
                      ),
                    ],
                  ),
                ),
              );

            },
          );
        },
      ),
    );


  }



  }


