
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utiles/Utiles.dart';
import 'package:firebase_auth/firebase_auth.dart';

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




  Future<void> showFiles(BuildContext context, String categoryFolder,String profileId) async {
    final provider = Provider.of<Loadingstate>(context, listen: false);

    // Safety Check: If no user is logged in, stop here
    if (profileId == null) {
      Utiles().toastMessage("No Profile Selected.");
      return;
    }

    provider.setloading(true);

    try {
      // 2. Construct the User-Specific Path
      // Logic: Look inside the folder named after the UID, then the category
      final String userSpecificPath = '$profileId/$categoryFolder';

      // 3. Fetch list from that path
      final List<FileObject> responsefile = await supaBaseRef.storage
          .from("files")
          .list(path: userSpecificPath);

      provider.setAllFiles(responsefile);

    } catch (e) {
      Utiles().toastMessage("Storage Issue${e.toString()}");
    } finally {
      provider.setloading(false);
    }
  }

}