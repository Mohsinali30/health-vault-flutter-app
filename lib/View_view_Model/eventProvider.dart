import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/eventModel.dart';


class EventProvider with ChangeNotifier{
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isEditing = true; // Start in edit mode by default
  List<EventModel> _event=[];

  DateTime? get date => _selectedDate;
  TimeOfDay? get time => _selectedTime;
   bool get isEditing => _isEditing;
  List get event => _event;

  Future<void> getdata ()async{

    // 1. Current user ID lein
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return; // Agar user login nahi hai to wapis chale jayen

    // 2. Query mein 'where' lagayen
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Events")
        .where('userId', isEqualTo: uid) // ✅ Sirf is user ka data layega
        .get();
    // Load hone se pehle list clear karna zaroori hai, taaki duplicate na ho
    event.clear();

    for(DocumentSnapshot doc in snapshot.docs){
      var Eventdata = doc.data() as Map<String,dynamic>;
      event.add(EventModel.fromMap(Eventdata));
    }
    notifyListeners();
    setevent(event);

  }

  void setevent(event){
    _event=event;
    notifyListeners();
  }

   void setisEditing(bool isEditing){
     _isEditing=isEditing;
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