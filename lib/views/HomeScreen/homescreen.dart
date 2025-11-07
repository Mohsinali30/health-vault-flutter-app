import 'package:firebase_practice/tips_Screen.dart';
import 'package:firebase_practice/views/AddEvents/EventScreen.dart';
import 'package:firebase_practice/views/Upload_Docs/Viewallfiles.dart';
import 'package:firebase_practice/views/profile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Supabase_services/bucketoperations.dart';
import '../../View_view_Model/provider.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/QuickActionButton.dart';
import '../../utiles/RecentActivityCard.dart';
import '../Upload_Docs/uploadScreen.dart' hide primaryGreen, lightGreen;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Loadingstate>(context, listen: false);
      // Assuming 'fetchallFiles' is now correctly moved to your provider class (as advised previously)
      provider.showFiles(context, provider.category);
    });
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=> MyProfileScreen()));
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
            final files = provider.allFiles; // 💡 List Yahan Se Mil Jayegi 💡
            final recentFiles = files.take(2).toList();
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
                         Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const UploadScreen())
                         );
                         break;
                       case 1:
                         Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) =>  Viewallfiles())
                         );
                         break;
                       case 2:
                         print("Navigate to Prescriptions screen");
                         break;
                       case 3:
                         print("Navigate to Reminders screen");
                         break;
                       case 4:
                         Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) =>  EventScreen())
                         ) ;
                         break;
                       case 5:
                         Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) =>  ShowTipsScreen())
                         ) ;
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
            itemCount:recentFiles.length,
            itemBuilder: (context, index) {
            final file = recentFiles[index];
            return RecentActivityCard(
            icon: Icons.drive_file_move_outline,
            title:'${file.name}',
            subtitle: '',
            onViewDetails:()=>BucketOperation().DownloadAndOpen(file.name),
            buttonicon: 'view',

            );
            }

       // Spacing at the bottom
            )]
            ),

    );})
      );
  }
}