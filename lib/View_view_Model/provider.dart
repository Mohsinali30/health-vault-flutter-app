
import'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loadingstate with ChangeNotifier{
  bool _Loading=false;
  bool get isLoading => _Loading;

  void setloading(bool load){
    _Loading =load;
notifyListeners();
  }

  List<FileObject> _allFiles = []; // Private list

  List<FileObject> get allFiles => _allFiles; // Public getter for list

  // 💡 Naya Setter Method 💡
  void setAllFiles(List<FileObject> files) {
    _allFiles = files;
    notifyListeners(); // Jab list update ho to listeners ko inform karein
  }

}