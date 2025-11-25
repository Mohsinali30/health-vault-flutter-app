import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
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
  StreamSubscription<QuerySnapshot>?
  _eventSubscription;
  Future<void> getdata ()async{
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    _eventSubscription = await FirebaseFirestore.instance
        .collection("Events")
        .where('userId', isEqualTo: uid) // ✅ Sirf is user ka data layega
        .snapshots().listen((snapshot){

        // Load hone se pehle list clear karna zaroori hai, taaki duplicate na ho
        event.clear();

        for(DocumentSnapshot doc in snapshot.docs){
      var Eventdata = doc.data() as Map<String,dynamic>;
      event.add(EventModel.fromMap(Eventdata,doc.id));
    }
    notifyListeners();
    });

  }

  Future<void> deleteEvent (String docid)async {
      await FirebaseFirestore.instance.collection("Events").doc(docid).delete().then((value){
        notifyListeners();
        Utiles().toastMessage("Event deleted");
      });

  }

  void setevent(event){
    _event=event;
    notifyListeners();
    getdata();
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