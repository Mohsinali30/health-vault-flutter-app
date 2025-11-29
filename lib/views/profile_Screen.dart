import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/models/userBioModel.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:firebase_practice/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../View_view_Model/bioProvider.dart';
import '../utiles/AppColors.dart';
import '../utiles/ProfilecustomField.dart';




class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController dobcontroller = TextEditingController();
  TextEditingController gendercontroller = TextEditingController();
  TextEditingController bgroupcontroller = TextEditingController();

  Future<void> addBio (BioModel bio ) async{
    FirebaseFirestore db =FirebaseFirestore.instance;
    try{
      await db.collection("UserBio").doc(bio.userId).set(BioModel.toMap(bio, context),
          SetOptions(merge: true) // Optional: merge ensures we update fields, not just overwrite
      ).then((value)=>{
        Utiles().toastMessage("Added Successfully")
      });
    }catch(e){
      Utiles().toastMessage(e.toString());
    }
  }
  final auth = FirebaseAuth.instance;
  final uid = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // Fetch data immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BioProvider>(context, listen: false);

      // Controllers pass karein taake Provider unhein fill kar sake
      provider.getProfileData(
          namecontroller,
          emailcontroller,
          dobcontroller,
          gendercontroller,
          bgroupcontroller
      );
    });
  }

  @override
  void dispose() {
    // 1. Saare Controllers ko dispose karein
    namecontroller.dispose();
    emailcontroller.dispose();
    dobcontroller.dispose();
    gendercontroller.dispose();
    bgroupcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final uid = FirebaseAuth.instance.currentUser;
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

      body: Consumer<BioProvider>(builder: ( context,value,child){
        return  SafeArea(
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

                      ProfileCustomField(
                        controll:namecontroller,
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll:emailcontroller,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll: dobcontroller,
                        icon: Icons.calendar_today_outlined,
                        label: 'Date of Birth',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll: gendercontroller,
                        icon: Icons.male_outlined,
                        label: 'Gender',
                        readOnly: !value.isEditing,
                      ),
                      ProfileCustomField(
                        controll: bgroupcontroller,
                        icon: Icons.bloodtype_outlined,
                        label: 'Blood Group',
                        readOnly: !value.isEditing,
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
                      onPressed: () async {
                        if (!value.isEditing) {
                          value.setisEditing(true);
                          return; // Aage ka code (Save wala) na chale
                        }
                        if (uid == null) {
                          Utiles().toastMessage("User not logged in!");
                          return;
                        }
                        BioModel bio =BioModel(
                          fullname: namecontroller.text.toString(),
                          email: emailcontroller.text.toString(),
                          dob: dobcontroller.text.toString(),
                          gender: gendercontroller.text.toString(),
                          bgroup: bgroupcontroller.text.toString(),
                          userId: uid.uid,
                        );
                         addBio(bio);
                           value.setisEditing(false);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                      ),
                      child:  Text(
                        value.isEditing ? 'Save Changes' : 'Edit Profile',
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
        );

      })


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