import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:firebase_practice/views/HomeScreen/homescreen.dart';
import 'package:firebase_practice/views/auth/SignUp_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../View_view_Model/provider.dart';
import '../../utiles/customtextfield.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Define GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();


  final emailController = TextEditingController();
  final passController = TextEditingController();

  // 3. Dispose controllers when the widget is removed
  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _handleSignIn(BuildContext context, email,password) {
    final loadingprovider = Provider.of<Loadingstate>(context, listen: false);

    // Check validation state using the FormKey
    if (_formKey.currentState!.validate()) {
      loadingprovider.setloading(true);
      // Validation succeeded
     auth.signInWithEmailAndPassword(email: email.text, password: password.text).then((value){
       Utiles().toastMessage(value.user!.email.toString());
       // Navigate to HomeScreen
       Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
       loadingprovider.setloading(false);
     }).onError((error,stackTrace){
       Utiles().toastMessage(error.toString());
       loadingprovider.setloading(false);
     })    ;


    } else {
      // Validation failed
      Utiles().toastMessage("Enter email and password");
    }
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
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
                'Welcome Back',
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
                child: TextButton(
                  // Call the handler function
                  onPressed: () => _handleSignIn(context,emailController,passController),
                  child: isloading? const CircularProgressIndicator(color: whiteColor,strokeWidth: 3.0,) : Text(
                    'Login ',
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
                  Text("don't have an account? ",style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  )),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpScreen()));
                  }, child: Text("Sign Up",style: TextStyle(
                    color: whiteColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),),)
                ],
              ),

          /*
        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextButton(

                // Call the handler function
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginWithPhonenumber()));
                },
                child: Text(
                  'Login with Phone Number ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),*/

            ],
          ),
        ),
      ),
    );
  }
}