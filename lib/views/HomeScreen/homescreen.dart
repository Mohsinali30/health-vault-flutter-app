import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/View_view_Model/bioProvider.dart';
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
    super.initState();
    saveDataToSupabase();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Loadingstate>(context, listen: false);
      final bio = Provider.of<BioProvider>(context, listen: false);
      final profileId = bio.activeProfile?.docId;

      if (profileId != null) {
        provider.showFiles(context, provider.category, profileId);
      }
    });
  }

  Future<void> saveDataToSupabase() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print("User not logged in via Firebase");
      return;
    }

    final String uid = firebaseUser.uid;

    await Supabase.instance.client
        .from('Users')
        .insert({'id': uid, 'created_at': DateTime.now().toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    // Get BioProvider to show name in Drawer (Optional)
    final bio = Provider.of<BioProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ---------------------------------------------------------
      // 1. ADDED DRAWER HERE
      // ---------------------------------------------------------
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryGreen),
              accountName: Text(
                bio.activeProfile?.fullname ?? "Health Vault User",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Manage your health records"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: primaryGreen),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: primaryGreen),
              title: const Text('Upload Report'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, 'UploadScreen');
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryGreen),
              title: const Text('Medical History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'AllFile');
              },
            ),
            ListTile(
              leading: Icon(Icons.medication, color: primaryGreen),
              title: const Text('Prescriptions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'Precription');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: primaryGreen),
              title: const Text('Appointments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'AddEvent');
              },
            ),
            const Divider(), // Separator line
            ListTile(
              leading: Icon(Icons.person_outline, color: primaryGreen),
              title: const Text('User Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'SelectProfileScreen');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        // ---------------------------------------------------------
        // 2. CHANGED: Removed automaticallyImplyLeading: false
        // This allows the Drawer Icon (Hamburger) to show up on the left
        // ---------------------------------------------------------
        backgroundColor: primaryGreen,
        title: const Text(
          'Health Vault',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Profile Setting',
              onPressed: () {
                Navigator.pushNamed(context, 'SelectProfileScreen');
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: Container(),
        ),
      ),
      body: Consumer<Loadingstate>(builder: (context, provider, child) {
        final files = provider.allFiles
            .where((files) => !files.name.contains('.emptyFolderPlaceholder'))
            .toList();
        final recentFiles = files.take(4).toList();
        if (provider.isLoading && provider.allFiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 1. Welcome Card Section
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final List<Map<String, dynamic>> quickActions = [
                    {'icon': Icons.upload_file, 'label': 'Upload Reports'},
                    {'icon': Icons.history, 'label': 'Medical History'},
                    {'icon': Icons.medication, 'label': 'Prescriptions'},
                    {'icon': Icons.notifications_active, 'label': 'Reminders'},
                    {'icon': Icons.calendar_month, 'label': 'Appointments'},
                    {'icon': Icons.health_and_safety, 'label': 'Wellness Tips'},
                  ];

                  return QuickActionButton(
                    icon: quickActions[index]['icon'],
                    label: quickActions[index]['label'] as String,
                    onTap: () {
                      switch (index) {
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
                final reverselist = recentFiles.length - 1 - index;
                final file = recentFiles[reverselist];
                final bio = Provider.of<BioProvider>(context, listen: false);
                final ProfileID = bio.activeProfile!.docId;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Card(
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.file_copy_outlined, color: Colors.green, size: 22),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Recently Added",
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            BucketOperation().DownloadAndOpen('$ProfileID/${provider.category}/${file.name}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
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
            ),
          ]),
        );
      }),
    );
  }
}