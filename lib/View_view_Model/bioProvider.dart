import 'package:firebase_practice/models/userBioModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BioProvider with ChangeNotifier {

  // 1. State Variables
  bool _isEditing = false;
  bool _isLoading = false;
  BioModel? _userBio; // To store the fetched data

  // 2. Getters
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  BioModel? get userBio => _userBio;

  // 3. Setters
  void setisEditing(bool isEditing) {
    _isEditing = isEditing;
    notifyListeners();
  }

  // 4. Main Function: Get Data & Validate
  Future<void> getProfileData(TextEditingController nameC, TextEditingController emailC, TextEditingController dobC, TextEditingController genderC, TextEditingController bloodC) async {

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
      print("Error fetching bio: $e");
    }

    // Step E: Stop Loading
    _isLoading = false;
    notifyListeners();
  }
}