import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../View_view_Model/bioProvider.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/ProfilecustomField.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Controllers
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController dobcontroller = TextEditingController();
  final TextEditingController gendercontroller = TextEditingController();
  final TextEditingController bgroupcontroller = TextEditingController();
  final TextEditingController relationcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BioProvider>(context, listen: false);
    final profile = provider.selectedProfile;

    if (profile != null) {
      namecontroller.text = profile.fullname;
      emailcontroller.text = profile.email ?? "";
      dobcontroller.text = profile.dob ?? "";
      gendercontroller.text = profile.gender ?? "";
      bgroupcontroller.text = profile.bgroup ?? "";
      relationcontroller.text = profile.Relation ?? "";
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    dobcontroller.dispose();
    gendercontroller.dispose();
    bgroupcontroller.dispose();
    relationcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BioProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: Colors.grey[100], // Light grey background
        appBar: AppBar(
          backgroundColor: primaryGreen,
          elevation: 0,
          centerTitle: true,
          title: Text(
            value.selectedProfile == null ? 'Add Member' : 'Profile Details',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            if (value.selectedProfile != null)
              IconButton(
                tooltip: "Delete Profile",
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _showDeleteDialog(context, value),
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. HEADER SECTION (Curved Background + Avatar)
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Green Curve Background
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  // Profile Picture overlapping the curve
                  Positioned(
                    top: 20,
                    child: _buildProfilePicture(value),
                  ),
                ],
              ),

              const SizedBox(height: 80), // Space for the overlapping avatar

              // 2. FORM SECTION (White Card)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Personal Information"),
                      const SizedBox(height: 15),
                      ProfileCustomField(
                        controll: namecontroller,
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll: relationcontroller,
                        icon: Icons.family_restroom_rounded,
                        label: 'Relation (e.g. Brother)',
                        readOnly: !value.isEditing,
                      ),

                      const SizedBox(height: 20),
                      _buildSectionTitle("Contact & Bio"),
                      const SizedBox(height: 15),

                      ProfileCustomField(
                        controll: emailcontroller,
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll: dobcontroller,
                        icon: Icons.calendar_today_rounded,
                        label: 'Date of Birth',
                        readOnly: !value.isEditing,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileCustomField(
                              controll: gendercontroller,
                              icon: Icons.male_rounded,
                              label: 'Gender',
                              readOnly: !value.isEditing,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProfileCustomField(
                              controll: bgroupcontroller,
                              icon: Icons.bloodtype_outlined,
                              label: 'Blood Group',
                              readOnly: !value.isEditing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. ACTION BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!value.isEditing) {
                        value.setisEditing(true);
                      } else {
                        value.saveProfile(
                            namecontroller.text,
                            emailcontroller.text,
                            dobcontroller.text,
                            gendercontroller.text,
                            bgroupcontroller.text,
                            relationcontroller.text,
                            context
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: value.isLoading
                        ? const SizedBox(
                      width: 25, height: 25,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(value.isEditing ? Icons.save_rounded : Icons.edit_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          value.isEditing ? 'Save Changes' : 'Edit Profile',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProfilePicture(BioProvider value) {
    ImageProvider getImage() {
      if (value.profileimage != null) return FileImage(value.profileimage!);
      if (value.selectedProfile?.Profileimage != null && value.selectedProfile!.Profileimage!.isNotEmpty) {
        return NetworkImage(value.selectedProfile!.Profileimage!);
      }
      return const AssetImage('assets/image.png');
    }

    return Stack(
      children: [
        // Avatar Ring
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: CircleAvatar(
            radius: 60, // Bigger size
            backgroundColor: Colors.grey[200],
            backgroundImage: getImage(),
          ),
        ),

        // Edit Camera Button
        if (value.isEditing)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => value.PickImage(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, BioProvider value) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Delete Profile"),
        content: const Text("Are you sure you want to delete this family member? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              value.deleteProfile(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}