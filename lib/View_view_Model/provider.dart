
import'package:flutter/foundation.dart';

class Loadingstate with ChangeNotifier{
  bool _Loading=false;
  bool get isLoading => _Loading;

  void setloading(bool load){
    _Loading =load;
notifyListeners();
  }
}