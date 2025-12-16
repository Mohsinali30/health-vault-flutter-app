import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_practice/View_view_Model/bioProvider.dart';
import 'package:firebase_practice/models/userBioModel.dart';
import '../../utiles/Utiles.dart';

class Profileselectioscreen extends StatefulWidget {
  const Profileselectioscreen({super.key});

  @override
  State<Profileselectioscreen> createState() => _ProfileselectioscreenState();
}

class _ProfileselectioscreenState extends State<Profileselectioscreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BioProvider>(context, listen: false).fetchAllProfiles();
    });
  }

  // --- LOGOUT FUNCTION ---
  void _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        // Clear provider state if necessary
        if(mounted) {
          Provider.of<BioProvider>(context, listen: false).clearSelectedProfile();
          // Navigate to Login Screen (Replace 'LoginScreen' with your actual route name)
          Navigator.pushNamedAndRemoveUntil(context, 'LoginScreen', (route) => false);
        }
      } catch (e) {
        Utiles().toastMessage(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
   final bio= Provider.of<BioProvider>(context, listen: false);
   final profileName = bio.activeProfile?.fullname ?? "Guest";
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title:
        Consumer<BioProvider>( // Consumer use karein takay switch hote hi name change ho
          builder: (context, provider, child) {
            final profileName = provider.activeProfile?.fullname ?? "Guest";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(profileName, style: const TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Provider.of<BioProvider>(context, listen: false).clearSelectedProfile();
                Navigator.pushNamed(context, 'UserProfile');
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.green),
              tooltip: "Add New Member",
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // --- PROFILE GRID ---
          Expanded(
            child: Consumer<BioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }
                if (provider.profilesList.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.8, // Taller cards
                  ),
                  itemCount: provider.profilesList.length,
                  itemBuilder: (context, index) {
                    return _buildModernProfileCard(context, provider.profilesList[index]);
                  },
                );
              },
            ),
          ),

          // --- LOGOUT BUTTON AT BOTTOM ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN PROFILE CARD WIDGET ---
  Widget _buildModernProfileCard(BuildContext context, BioModel profile) {
    final provider = Provider.of<BioProvider>(context);

    // Active Logic
    bool isActive = false;
    if (provider.activeProfile?.docId != null && profile.docId != null) {
      isActive = provider.activeProfile!.docId == profile.docId;
    }

    return GestureDetector(
      onTap: () {
        if (profile.docId == null) {
          Utiles().toastMessage("Error: Invalid Profile ID");
          return;
        }
        provider.setActiveProfile(profile);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.green : Colors.transparent,
            width: isActive ? 2.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            // Edit Button (Top Right)
            Positioned(
              right: 8,
              top: 8,
              child: InkWell(
                onTap: () {
                  provider.setSelectedProfile(profile);
                  Navigator.pushNamed(context, 'UserProfile');
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                ),
              ),
            ),

            // Checkmark (Top Left - Only if active)
            if (isActive)
              const Positioned(
                left: 10,
                top: 10,
                child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with Ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isActive ? Colors.green : Colors.grey.shade200, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: (profile.Profileimage != null && profile.Profileimage!.isNotEmpty)
                          ? NetworkImage(profile.Profileimage!)
                          : const AssetImage('assets/image.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      profile.fullname,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green.shade800 : Colors.black87,
                      ),
                    ),
                  ),

                  // Relation or Status Text
                  const SizedBox(height: 4),
                  Text(
                    isActive ? "Selected" : "Tap to select",
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green : Colors.grey,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No family members yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Provider.of<BioProvider>(context, listen: false).clearSelectedProfile();
              Navigator.pushNamed(context, 'UserProfile');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Add Member", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}