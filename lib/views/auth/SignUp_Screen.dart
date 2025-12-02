import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utiles/AppColors.dart';
import '../../utiles/customtextfield.dart';




class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Define GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();
  // 2. Define controllers inside the State class
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmpassController = TextEditingController();
  // 3. Dispose controllers when the widget is removed
  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    confirmpassController.dispose();
    super.dispose();
  }

  void _handleSignIn(BuildContext context,emailController,password){
  final loadingprovider = Provider.of<Loadingstate>(context, listen: false);
    // Check validation state using the FormKey
    if (_formKey.currentState!.validate()) {
        loadingprovider.setloading(true);
      // Validation succeeded
      auth.createUserWithEmailAndPassword(email: emailController.text.toString(),
          password: password.text.toString()).then((value){
        Navigator.pushNamed(context, 'Login');
        loadingprovider.setloading(false);
        Utiles().toastMessage("Account Created Successfully");
      }
      ).onError((error,stackTrace){
             Utiles().toastMessage("User not found");
             loadingprovider.setloading(false);
      });
    } else {
      // Validation failed
      Utiles().toastMessage('User not exsist');
    }
  }
  FirebaseAuth auth= FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Form(
                key: _formKey, // Attach the key to the Form
                child: Column(
                  children: [
                    // Ensure your CustomTextField uses 'controller' as the argument name
                    CustomTextField(
                      icon: Icons.email_outlined,
                      hintText: 'Email',
                      isPassword: false,
                      controller: emailController, // Pass the controller
                    ),
                    CustomTextField(
                      icon: Icons.lock_outline,
                      hintText: 'Password',
                      isPassword: true,
                      controller: passController, // Pass the controller
                    ),
                    CustomTextField(
                      icon: Icons.lock_outline,
                      hintText: 'Re-Enter-Password',
                      isPassword: true,
                      controller: confirmpassController, // Pass the controller
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- Sign In Button Section ---
            Consumer<Loadingstate>(builder: (context,value,child) {
              bool isloading =value.isLoading;
              return
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child:
                  ElevatedButton(
                    onPressed: () => _handleSignIn(context,emailController,confirmpassController),
                    child:  isloading? const CircularProgressIndicator(color: whiteColor,strokeWidth: 3.0,) : Text(
                      'Sign Up ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ButtonStyle(shadowColor: WidgetStatePropertyAll(Colors.black12,),elevation:WidgetStatePropertyAll(12)  ),
                  ),
                );
            }),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",style: TextStyle(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              )),
                  TextButton(onPressed: (){
                    Navigator.pushNamed(context, 'Login');
                    }, child:
                  Text("Login ",style: TextStyle(
                    color: whiteColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}