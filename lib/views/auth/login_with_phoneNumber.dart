import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:firebase_practice/views/auth/login_screen.dart';
import 'package:firebase_practice/views/auth/verify_code.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../View_view_Model/provider.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/customtextfield.dart';

class LoginWithPhonenumber extends StatefulWidget {
  const LoginWithPhonenumber({super.key});

  @override
  State<LoginWithPhonenumber> createState() => _LoginWithPhonenumberState();
}

class _LoginWithPhonenumberState extends State<LoginWithPhonenumber> {


  final phoneNumberController= TextEditingController();
bool loading=false;
final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // --- Icon/Logo Section ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 40.0,
                    color: primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Text Section ---
              const Text(
                'Welcome ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access your health records',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.0,
                ),
              ),

              const SizedBox(height: 40),

              // 4. Wrap Input Fields in the Form widget

               Column(
                  children: [
                    // Ensure your CustomTextField uses 'controller' as the argument name
                    CustomTextField(
                      icon: Icons.phone,
                      hintText: '+92 30123456789',
                      isPassword: false,
                      controller: phoneNumberController, // Pass the controller
                    ),

                  ],
                ),


              const SizedBox(height: 30),

              // --- Sign In Button Section ---
              Consumer<Loadingstate>(builder: (context,value,child) {
                return
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextButton(
                      // Call the handler function
                   onPressed: (){
                     auth.verifyPhoneNumber(
                       phoneNumber: phoneNumberController.text,
                         verificationCompleted: (_){

                         },
                         verificationFailed: (e){
                         Utiles().toastMessage(e.toString());
                         },
                         codeSent: (String vrificationid, int? token){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=> VerifyCode(verficationId:vrificationid )));
                         },
                         codeAutoRetrievalTimeout: (e){
                         Utiles().toastMessage(e.toString());
                     });
                     
                   },
                      child:Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );}),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Login with email? ",style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  )),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                  }, child: Text("Login Up",style: TextStyle(
                    color: whiteColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
