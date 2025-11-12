

import 'package:flutter/foundation.dart';

class IsAdding with ChangeNotifier{
  bool _isaddingevent =false;

  bool get isadding => _isaddingevent;


  void setisAdding(bool value){
    _isaddingevent=value;
    notifyListeners();
  }

}