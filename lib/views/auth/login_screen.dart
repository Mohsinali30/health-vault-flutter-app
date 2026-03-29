import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:firebase_practice/views/HomeScreen/homescreen.dart';
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
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _handleSignIn(BuildContext context) {
    // Dismiss keyboard first for better UX
    FocusScope.of(context).unfocus();

    final loadingprovider = Provider.of<Loadingstate>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      loadingprovider.setloading(true);

      auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim()
      ).then((value) {
        Utiles().toastMessage("Login Successfully");
        loadingprovider.setloading(false);
        // Use pushReplacement to prevent going back to login screen on back press
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }).onError((error, stackTrace) {
        Utiles().toastMessage(error.toString());
        loadingprovider.setloading(false);
      });
    } else {
      Utiles().toastMessage("Please enter valid email and password");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive adjustments
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryGreen,
      // GestureDetector dismisses keyboard when tapping empty space
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),

                          // --- Icon/Logo Section ---
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded, // Changed to a more medical icon
                                size: 45.0,
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
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to access your health records',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16.0,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- Form Section ---
                          AutofillGroup( // Enables native autofill suggestions
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    icon: Icons.email_outlined,
                                    hintText: 'Email',
                                    isPassword: false,
                                    controller: emailController,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    icon: Icons.lock_outline,
                                    hintText: 'Password',
                                    isPassword: true,
                                    controller: passController,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // --- Forgot Password ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'ForgotScreen');
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- Login Button ---
                          Consumer<Loadingstate>(
                            builder: (context, value, child) {
                              return SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () => _handleSignIn(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryGreen,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: value.isLoading
                                      ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: primaryGreen,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // --- Social Login Divider (Optional but good UX) ---
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Or continue with",
                                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                          const SizedBox(height: 20),



                          // --- Sticky Bottom Spacer ---
                          const Spacer(),

                          // --- Footer ---
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.0,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'Signup');
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


}