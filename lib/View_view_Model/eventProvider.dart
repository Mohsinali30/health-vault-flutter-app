import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import '../models/eventModel.dart';

class EventProvider with ChangeNotifier {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isreminder = false;
  bool _isEditing = true;
  List<EventModel> _event = [];

  bool get isreminder => _isreminder;
  DateTime? get date => _selectedDate;
  TimeOfDay? get time => _selectedTime;
  bool get isEditing => _isEditing;
  List<EventModel> get event => _event; // Fixed List type

  StreamSubscription<QuerySnapshot>? _eventSubscription;

  // --- CHANGE 1: Accept profileId as a parameter ---
  Future<void> getdata(String profileId) async {
    // Cancel previous subscription if it exists (prevents data mixing)
    await _eventSubscription?.cancel();

    try {
      // --- CHANGE 2: Update Path to Sub-collection ---
      // Path: UserBio -> {profileId} -> Events
      _eventSubscription = FirebaseFirestore.instance
          .collection("UserBio")
          .doc(profileId) // Using the specific Selected Profile ID
          .collection("Events")
          .snapshots()
          .listen((snapshot) {

        _event.clear(); // Clear list before adding new data

        for (DocumentSnapshot doc in snapshot.docs) {
          var Eventdata = doc.data() as Map<String, dynamic>;
          // Ensure your EventModel handles the data correctly
          _event.add(EventModel.fromMap(Eventdata, doc.id));
        }
        notifyListeners();
      });
    } catch (e) {
      Utiles().toastMessage(e.toString());
    }
  }

  // --- CHANGE 3: Update Delete to look inside the specific profile ---
  Future<void> deleteEvent(String docid, String profileId) async {
    try {
      await FirebaseFirestore.instance
          .collection("UserBio")
          .doc(profileId) // Need profileId to find the path
          .collection("Events")
          .doc(docid)
          .delete()
          .then((value) {
        // notifyListeners(); // Snapshot listener handles this automatically
        Utiles().toastMessage("Event deleted");
      });
    } catch (e) {
      Utiles().toastMessage(e.toString());
    }
  }

  // --- CHANGE 4: Update Reminder logic for specific profile ---
  Future<void> deleteReminder(String docid, String profileId) async {
    try {
      await FirebaseFirestore.instance
          .collection("UserBio")
          .doc(profileId)
          .collection("Events")
          .doc(docid)
          .update({"isreminder": false});

      // notifyListeners(); // Snapshot listener handles this
      Utiles().toastMessage("Reminder deleted");
    } catch (e) {
      Utiles().toastMessage(e.toString());
    }
  }

  // --- BONUS: Function to ADD Event to the selected profile ---
  Future<void> addEvent(EventModel eventModel, String profileId) async {
    try {
      await FirebaseFirestore.instance
          .collection("UserBio")
          .doc(profileId)
          .collection("Events")
          .add(EventModel.toMap(eventModel));// Assuming your model has toMap()

      Utiles().toastMessage("Event Added Successfully");
    } catch (e) {
      Utiles().toastMessage(e.toString());
    }
  }

  // ... (Rest of your setters: setDate, setTime, etc. remain the same)
  void set_isreminder(bool isreminder){
    _isreminder=isreminder;
    notifyListeners();
  }

  void setisEditing(bool setisEditing){
    _isEditing=setisEditing;
    notifyListeners();
  }

  void setDate( DateTime selectedDate){
    _selectedDate=selectedDate;
    notifyListeners();
  }

  void setTime(TimeOfDay selectedTime){
    _selectedTime=selectedTime;
    notifyListeners();
  }
}