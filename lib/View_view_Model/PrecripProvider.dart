import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utiles/Utiles.dart';
import '../views/Prescription/ImageViewScreen.dart';

class PrecripProvider with ChangeNotifier {
  File? _image;

  File? get image => _image;

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex; // Fixed naming convention

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final picker = ImagePicker();

  void setLoading(bool load) {
    _isLoading = load;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final imagePicked = await picker.pickImage(source: source);
      if (imagePicked != null) {
        _image = File(imagePicked.path);
        notifyListeners();
      } else {
        Utiles().toastMessage("No Image Selected");
      }
    } catch (e) {
      Utiles().toastMessage(e.toString());
    }
  }

  void clearImage() {
    _image = null;
    _selectedIndex = 0;
    notifyListeners();
  }

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();

    if (index == 0) {
      clearImage();
    } else if (index == 1) {
      pickImage(ImageSource.camera);
    } else if (index == 2) {
      pickImage(ImageSource.gallery);
    }
  }


  List<FileObject> _allFiles = []; // Private list

  List<FileObject> get allFiles => _allFiles; // Public getter for list
  void setAllFiles(List<FileObject> files) {
    _allFiles = files;
    notifyListeners(); // Jab list update ho to listeners ko inform karein
  }


  Future<void>  showFiles(context)async{
    setLoading(true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final supaBaseRef= Supabase.instance.client;

    try{
      final List<FileObject> responsefile = await supaBaseRef.storage.
      from("preciptionorrecipt").list(path: "$uid/receipts");
      setAllFiles(responsefile);
      notifyListeners();
    }catch(e){
      Utiles().toastMessage(e.toString());
    }
    setLoading(false);
  }





}


