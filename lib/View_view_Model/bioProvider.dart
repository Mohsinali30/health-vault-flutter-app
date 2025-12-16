import 'dart:io';
import 'package:firebase_practice/models/userBioModel.dart'; // Import your model
import 'package:firebase_practice/utiles/Utiles.dart'; // Import your utils
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BioProvider with ChangeNotifier {
  File? _profileimage;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isuploading = false;
  BioModel? _activeProfile; // Stores the currently selected user

  BioModel? get activeProfile => _activeProfile;

  // List to store multiple profiles
  List<BioModel> _profilesList = [];

  // Currently selected profile for editing/viewing
  BioModel? _selectedProfile;

  // Getters
  List<BioModel> get profilesList => _profilesList;
  BioModel? get selectedProfile => _selectedProfile;
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  bool get isuploading => _isuploading;
  File? get profileimage => _profileimage;

  final ImagePicker picker = ImagePicker();

  // Function to set the active profile
  void setActiveProfile(BioModel profile) async{
    _activeProfile = profile;
    notifyListeners(); // UI will update to show selection
    final pref =await SharedPreferences.getInstance();
    if(profile.docId != null){
      await pref.setString('saved_profile_id', profile.docId!);
      Utiles().toastMessage("Switched to ${profile.fullname}");

    }}


    // Is function ko tab call karein jab aap Firebase se Profiles fetch kar chuke hon
// --- A. JAB APP CHALAY TO LAST PROFILE LOAD KARE ---
    Future<void> loadLastSelectedProfile() async {
      final prefs = await SharedPreferences.getInstance();
      // Memory se ID nikalein
      String? savedId = prefs.getString('saved_profile_id');

      // Agar ID mili aur hamari List khali nahi hai
      if (savedId != null && _profilesList.isNotEmpty) {
        try {
          // List mein se wo banda dhoond kar active set karein
          _activeProfile = _profilesList.firstWhere((element) => element.docId == savedId);
        } catch (e) {
          Utiles().toastMessage("Profile doesn't exists");
        //  print("Saved profile shyad delete ho gayi ho");
        }
      }
    }


  // --- SETTERS ---
  void setisEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }


  
  // Jab user "Add Profile" click kare
  void clearSelectedProfile() {
    _selectedProfile = null;
    _profileimage = null;
    _isEditing = true; // New profile is always in edit mode initially
    notifyListeners();
  }

  // Jab user kisi Card par click kare
  void setSelectedProfile(BioModel profile) {
    _selectedProfile = profile;
    _profileimage = null; // Clear local image, use URL from profile
    _isEditing = false; // View mode initially
    notifyListeners();
  }

  // --- IMAGE LOGIC (Same as before) ---
  Future<void> PickImage() async {
    try {
      final XFile? pickedImage = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50
      );
      if (pickedImage != null) {
        _profileimage = File(pickedImage.path);
        notifyListeners();
      } else {
      //  print("User ne image pick nahi ki");
      }
    } catch (e) {
    //  print("Pick Error: $e");
      Utiles().toastMessage("Permission denied or Error: $e");
    }
  }


  Future<String?> UploadProfileImage(String uid) async {
    final db = Supabase.instance.client;
    if (_profileimage == null) return _selectedProfile?.Profileimage; // Return old image if no new one

    _isuploading = true;
    notifyListeners();
    try {
      // Unique path for every profile image using Timestamp
      final String filepath = '$uid/profile/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await db.storage.from('users_profiles').upload(filepath, _profileimage!, fileOptions: FileOptions(upsert: true));
      final String imageurl = db.storage.from('users_profiles').getPublicUrl(filepath);
      return imageurl;
    } catch (e) {
      Utiles().toastMessage("Image Upload Error");
      return null;
    } finally {
      _isuploading = false;
      notifyListeners();
    }
  }

  // --- CRUD OPERATIONS ---

  // 1. Fetch All Profiles for Current User
  Future<void> fetchAllProfiles() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    // notifyListeners(); // Avoid rebuilds during build phase

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("UserBio")
          .where('userId', isEqualTo: uid)
          .get();

      _profilesList = snapshot.docs.map((doc) {
        return BioModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      await loadLastSelectedProfile();
    } catch (e) {
      Utiles().toastMessage(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Save or Update Profile
  Future<void> saveProfile(
      String name, String email, String dob, String gender, String bgroup, String relation, BuildContext context) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Upload Image First if selected
      String? imgUrl = await UploadProfileImage(uid);

      BioModel newBio = BioModel(
        fullname: name,
        email: email,
        dob: dob,
        gender: gender,
        bgroup: bgroup,
        Relation: relation,
        userId: uid,
        Profileimage: imgUrl ?? _selectedProfile?.Profileimage, // Use new URL or keep old
      );

      CollectionReference ref = FirebaseFirestore.instance.collection("UserBio");
      if (_selectedProfile == null) {
        // CASE 1: CREATE NEW PROFILE
        // .add() automatically creates a document with a random ID
        await ref.add(BioModel.toMap(newBio, context));
        Utiles().toastMessage("Profile Created Successfully");
      } else {
        // CASE 2: UPDATE EXISTING PROFILE
        // CHANGE: Use .set() with merge: true instead of .update()
        // This prevents the "not-found" error if the document is missing
        await ref.doc(_selectedProfile!.docId).set(
            BioModel.toMap(newBio, context),
            SetOptions(merge: true)
        );
        Utiles().toastMessage("Profile Updated Successfully");
      }

      // Refresh list after save
      await fetchAllProfiles();
      Navigator.pop(context); // Go back to grid

    } catch (e) {
      Utiles().toastMessage(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Delete Profile
  Future<void> deleteProfile(BuildContext context) async {
    if (_selectedProfile == null || _selectedProfile!.docId == null) return;

    try {
      await FirebaseFirestore.instance.collection("UserBio").doc(_selectedProfile!.docId).delete();
      Utiles().toastMessage("Profile Deleted");
      await fetchAllProfiles(); // Refresh list
      Navigator.pop(context); // Close detail screen
    } catch (e) {
      Utiles().toastMessage("Error deleting: $e");
    }
  }
}