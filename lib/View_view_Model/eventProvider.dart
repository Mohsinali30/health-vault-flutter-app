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