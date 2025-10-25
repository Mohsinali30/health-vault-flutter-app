import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:firebase_practice/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../utiles/AppColors.dart';
import '../utiles/ProfilecustomField.dart';




class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
final auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
           Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [

          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: IconButton(onPressed: (){
              auth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
              }).onError((error,stackTrace){
               Utiles().toastMessage(error.toString());
              });
            }, icon:  Icon(Icons.logout_outlined,color: whiteColor,size: 28,),
              tooltip: 'logout',),
          )


        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Section
              _buildProfilePicture(),
              const SizedBox(height: 30),

              // Personal Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),


                    const ProfileCustomField(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      initialValue: 'Mohsin Ali',
                      readOnly: false,
                    ),
                    const ProfileCustomField(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      initialValue: 'email.mail@example.com',
                    ),
                    const ProfileCustomField(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      initialValue: '2002-08-12',
                    ),
                    const ProfileCustomField(
                      icon: Icons.male_outlined,
                      label: 'Gender',
                      initialValue: 'Male',
                    ),
                    const ProfileCustomField(
                      icon: Icons.bloodtype_outlined,
                      label: 'Blood Group',
                      initialValue: 'B+',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save Changes Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: screenWidth,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement save logic
                      print('Save Changes button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the Profile Picture (for modularity)
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children:[
          // Profile Avatar Circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200, // Light grey background for the avatar
              border: Border.all(color: primaryGreen, width: 1),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: primaryGreen,
            ),
          ),
          // Edit Icon
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}