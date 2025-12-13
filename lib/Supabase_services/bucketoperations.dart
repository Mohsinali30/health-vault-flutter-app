

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class BucketOperation{
  final supaBaseRef = Supabase.instance.client;
     static Createbucket()async{
       final suparef= Supabase.instance.client;
       try{
         await suparef.storage.createBucket('documents');
         debugPrint("Bucket Created");
       } catch(e){
         Utiles().toastMessage(e.toString());
       }

     }


     Future<void> DownloadAndOpen(String filepath)async
     {//final provider= Provider.of<Loadingstate>(context,listen: false);/

       try{


       final tempDir= await getTemporaryDirectory();
       final localpath = "${tempDir.path}/${filepath.split('/').last}";
       final localFile =File(localpath);
       final fileData = await supaBaseRef.storage.from("files").download(filepath);
       await localFile.writeAsBytes(fileData);
       await OpenFilex.open(localpath);

     }catch(e){
       Utiles().toastMessage(e.toString());
     }
   //  provider.setloading(false);
     }

     Future<void> DeleteFile(String filepath)async {       // final provider= Provider.of<Loadingstate>(context,listen: false);

    // provider.setloading(true);
     try{
       final fileData = await supaBaseRef.storage.from("files").remove([filepath]);
       if (fileData.isNotEmpty) {
         Utiles().toastMessage("${fileData[0].name} successfully deleted!");

        // provider.fetchallFiles(context);
         // Agar files list UI mein dikha rahe hain, toh us list ko refresh karein
         // Example: await fetchallFiles();
       } else {
         // Agar response empty hai ya unexpected hai
         Utiles().toastMessage("File deletion request sent.");
       }

     }catch(e){
       Utiles().toastMessage(e.toString());
     }
    // provider.setloading(false);
     }


}