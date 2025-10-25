

import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BucketOperation{

     static Createbucket()async{
       final suparef= Supabase.instance.client;

       try{
         await suparef.storage.createBucket('documents');
         debugPrint("Bucket Created");
       } catch(e){
         Utiles().toastMessage(e.toString());
       }

     }


}