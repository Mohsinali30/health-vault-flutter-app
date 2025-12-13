import 'dart:io';

import 'package:firebase_practice/models/userBioModel.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class BioProvider with ChangeNotifier {

  File? _profileimage;

  // 1. State Variables
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isuploading= false;
  BioModel? _userBio; // To store the fetched data

  // 2. Getters
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  bool get isuploading => _isuploading;
  BioModel? get userBio => _userBio;
  File? get profileimage => _profileimage;

  final ImagePicker picker= ImagePicker();

  //Image pick Logic
Future<void> PickImage()async{
  try{
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery,
    imageQuality: 50,
    );
      if(pickedImage != null){
        _profileimage = File(pickedImage.path);
        notifyListeners();
      }
  }catch(e){
    Utiles().toastMessage("Can not Pick Image");
  }

}


// Image Upload Logic
  Future<void> UploadProfileImage()async{
  final db = Supabase.instance.client;
  final user= FirebaseAuth.instance.currentUser;

if(profileimage ==null){
  Utiles().toastMessage("Please select an image first");
  return;
}  
  if(user == null){
    Utiles().toastMessage("user is not loggedin");
    return;
  }

    _isuploading= true;
  notifyListeners();
  try{
    //file path
    final String filepath = '${user.uid}/profile/avatar.jpg';
    //ulpoad to supabase
    await db.storage.from('users_profiles').upload(filepath, profileimage!,
        fileOptions:
        //Upsert: Overwrite old file
        FileOptions(upsert: true));

    final String imageurl = db.storage.from('users_profiles').
    getPublicUrl(filepath);

    await FirebaseFirestore.instance.collection('UserBio').
    doc(user.uid).update({'ProfileImage': imageurl});
    //Utiles().toastMessage("Profile Picture Updated!");
  }on StorageException catch(e){
    Utiles().toastMessage("Storage Error:${e.toString()}");
  }catch(e){
    Utiles().toastMessage("Error");
  }finally{
    _isuploading=false;
    notifyListeners();
  }
  }

  // 3. Setters
  void setisEditing(bool isEditing) {
    _isEditing = isEditing;
    notifyListeners();
  }




  // 4. Main Function: Get Data & Validate
  Future<void> getProfileData(TextEditingController nameC,
      TextEditingController emailC,
      TextEditingController dobC,
      TextEditingController genderC,
      TextEditingController bloodC,

      ) async {

    // Step A: Get Current User ID safely
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Step B: Start Loading
    _isLoading = true;
    notifyListeners();

    try {
      // Step C: Execute Query
      // Note: We use .get() to retrieve the data
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("UserBio")
          .where('userId', isEqualTo: uid) // Check spelling: 'userId' vs 'userid' in your DB
          .limit(1) // Optimization: We only expect 1 profile per user
          .get();

      // Step D: Validate if Data Exists
      if (snapshot.docs.isNotEmpty) {
        // --- SCENARIO 1: USER EXISTS ---

        // 1. Data ko Model mein convert karein
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        _userBio = BioModel.fromMap(data);
        // 2. Controllers mein data fill karein (UI Update)
        nameC.text = _userBio?.fullname ?? "";
        emailC.text = _userBio?.email ?? "";
        dobC.text = _userBio?.dob ?? "";
        genderC.text = _userBio?.gender ?? "";
        bloodC.text = _userBio?.bgroup ?? "";

        // 3. View Mode ON karein (Editing OFF)
        _isEditing = false;

      } else {
        // --- SCENARIO 2: NEW USER (NO DATA) ---

        // 1. Model null rakhein
        _userBio = null;

        // 2. Edit Mode ON karein (Taake user form fill kar sake)
        _isEditing = true;
      }
    } catch (e) {
      Utiles().toastMessage("Can't fetch data: ${e.toString()}");
    }

    // Step E: Stop Loading
    _isLoading = false;
    notifyListeners();
  }
}