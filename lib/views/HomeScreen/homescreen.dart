import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../Supabase_services/bucketoperations.dart';
import '../../View_view_Model/provider.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/QuickActionButton.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveDataToSupabase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Loadingstate>(context, listen: false);
      // Assuming 'fetchallFiles' is now correctly moved to your provider class (as advised previously)
      provider.showFiles(context, provider.category);
    });
  }

  Future<void> saveDataToSupabase() async {
    // 1. Get the Current User from Firebase
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print("User not logged in via Firebase");
      return;
    }

    final String uid = firebaseUser.uid;

    await Supabase.instance.client.from('Users').insert({'id': uid, 'created_at': DateTime.now().toIso8601String()});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Overall background is white
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryGreen, // Top app bar green
        title: const Text(
          'Health Vault',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions:[
      Padding(
        padding: EdgeInsets.only(right: 16.0),
        child: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 28,
          ),
          tooltip: 'Profile Setting',
          onPressed: () {
            Navigator.pushNamed(context, 'UserProfile');
          },
        ),
      ),

        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0), // No bottom line
          child: Container(),
        ),
      ),
      body: Consumer<Loadingstate>(
          builder: (context, provider, child) {
            final files = provider.allFiles
                .where((files) => !files.name.contains('.emptyFolderPlaceholder'))
                .toList();
            final recentFiles = files.take(4).toList();
            if (provider.isLoading && provider.allFiles.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            // List ki lambai (length) ko use karein
            return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            // 1. Welcome Card Section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: lightGreen, // Slightly lighter green for the card
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome to Health Vault!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Manage all your health records in one secure place.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                itemCount: 6, // 4 items shown in the image, adding 2 placeholders
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  // Example data for Quick Actions
                  final List<Map<String, dynamic>>
                  quickActions = [
                    {'icon':Icons.upload_file, 'label': 'Upload Reports'},
                    {'icon': Icons.history, 'label': 'Medical History'},
                    {'icon': Icons.medication, 'label': 'Prescriptions'},
                    {'icon': Icons.notifications_active, 'label': 'Reminders'},
                    // Add more if needed, or customize for actual functionality
                    {'icon': Icons.calendar_month, 'label': 'Appointments'},
                    {'icon': Icons.health_and_safety, 'label': 'Wellness Tips'},
                  ];

                  return QuickActionButton(
                    icon: quickActions[index]['icon'],
                    label: quickActions[index]['label'] as String,
                    onTap: () {
                     switch(index){
                       case 0:
                         Navigator.pushNamed(context, 'UploadScreen');
                         break;
                       case 1:
                         Navigator.pushNamed(context, 'AllFile');
                         break;
                       case 2:
                         Navigator.pushNamed(context, 'Precription');
                         break;
                       case 3:
                         Navigator.pushNamed(context, 'ReminderView');
                         break;
                       case 4:
                         Navigator.pushNamed(context, 'AddEvent');
                         break;
                       case 5:
                         Navigator.pushNamed(context, 'TipsView');
                         break;
                       default:
                         print('${quickActions[index]['label']} tapped!');
                     }
                    },
                  );
                },
              ),
            ),

            // 3. Recent Activity Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 10.0),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentFiles.length,
              itemBuilder: (context, index) {
                //Reverse List Logic WooHhooooo
                final reverselist = recentFiles.length -1-index;
                final file = recentFiles[reverselist];
                final uid =FirebaseAuth.instance.currentUser!.uid;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Card(
                    elevation: 3, // Halka shadow
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Soft corners
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0), // Inner spacing
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),

                        // 1. LEADING: File Icon with Background
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1), // Orange tint for "Recent" feel
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.file_copy_outlined, color: Colors.green, size: 22),
                        ),

                        // 2. TITLE: File Name
                        title: Text(
                          file.name ?? 'Unknown File',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor, // Aapka defined color
                          ),
                        ),

                        // 3. SUBTITLE: "Recently Viewed" text
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Recently Added", // Khali subtitle ki jagah ye behtar hai
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),

                        // 4. TRAILING: View Button
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: (){
                            BucketOperation().DownloadAndOpen('$uid/${provider.category}/${file.name}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1), // Green pill background
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryGreen.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View",
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: primaryGreen),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),]
            ),

    );})
      );
  }
}