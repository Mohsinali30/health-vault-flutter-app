
import'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utiles/Utiles.dart';

class Loadingstate with ChangeNotifier{
  final supaBaseRef = Supabase.instance.client;
  bool _Loading=false;
  bool get isLoading => _Loading;

  String _categoryFolder= 'diagnostics';
  String get category=> _categoryFolder;

  void setcategory(String  category){
    _categoryFolder =category;
    notifyListeners();
  }

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



  Future<void>  showFiles(context,categoryFolder)async{
    final provider= Provider.of<Loadingstate>(context,listen: false);
    provider.setloading(true);

    try{
      final List<FileObject> responsefile = await supaBaseRef.storage.from("files").list(path: categoryFolder);

      provider.setAllFiles(responsefile);
    }catch(e){
      Utiles().toastMessage(e.toString());
    }
    provider.setloading(false);
  }

}