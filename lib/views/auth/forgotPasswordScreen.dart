



import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../View_view_Model/provider.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/customtextfield.dart';

class Forgotpasswordscreen extends StatefulWidget {
  const Forgotpasswordscreen({super.key});

  @override
  State<Forgotpasswordscreen> createState() => _ForgotpasswordscreenState();
}
final emailController =TextEditingController();
final auth = FirebaseAuth.instance;
class _ForgotpasswordscreenState extends State<Forgotpasswordscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                icon: Icons.email_outlined,
                hintText: 'Email',
                isPassword: false,
                controller: emailController, // Pass the controller
              ),

              const SizedBox(height: 30),

        Consumer<Loadingstate>(builder: (context,value,child) {
          bool isloading = value.isLoading;
          return
            Padding(
              padding: const EdgeInsets.only(right: 20,left: 20),
              child: ElevatedButton(
                onPressed: () {
                  auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
                    Utiles().toastMessage("Password Reset Request send to Your Email");
                    Navigator.pop(context);
                  }).
                  onError((error,StackTrace){
                  Utiles().toastMessage(error.toString());
                  });
                },
                child: isloading ? const CircularProgressIndicator(
                  color: whiteColor, strokeWidth: 3.0,) : Text(
                  'Reset  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ButtonStyle(

                    shadowColor: WidgetStatePropertyAll(Colors.black12,),
                    elevation: WidgetStatePropertyAll(12)),
              ),
            );

        }
          )



            ],
          ),
    );
  }
}
