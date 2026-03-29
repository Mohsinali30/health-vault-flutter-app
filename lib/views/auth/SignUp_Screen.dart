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
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmpassController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    confirmpassController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context) {
    // 1. Hide Keyboard
    FocusScope.of(context).unfocus();

    final loadingprovider = Provider.of<Loadingstate>(context, listen: false);

    // 2. Local Validation for empty fields
    if (_formKey.currentState!.validate()) {

      // 3. Check if passwords match
      if (passController.text.trim() != confirmpassController.text.trim()) {
        Utiles().toastMessage("Passwords do not match");
        return;
      }

      loadingprovider.setloading(true);

      // 4. Firebase Creation
      auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      ).then((value) {
        loadingprovider.setloading(false);
        Utiles().toastMessage("Account Created Successfully");

        // Navigate back to Login or directly to Home depending on your flow
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        loadingprovider.setloading(false);
        Utiles().toastMessage(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive adjustments
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: primaryGreen,
      // Dismiss keyboard on tap
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
                          const SizedBox(height: 40),

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
                                Icons.person_add_alt_1_rounded, // Changed icon for Signup
                                size: 45.0,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // --- Text Section ---
                          const Text(
                            'Create Account',
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
                            'Join Health Vault to manage your life',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16.0,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- Form Section ---
                          AutofillGroup(
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
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    icon: Icons.lock_reset,
                                    hintText: 'Confirm Password',
                                    isPassword: true,
                                    controller: confirmpassController,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- Sign Up Button ---
                          Consumer<Loadingstate>(
                            builder: (context, value, child) {
                              return SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () => _handleSignUp(context),
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
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // --- Social Divider ---
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Or sign up with",
                                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                          const SizedBox(height: 20),



                          // --- Sticky Footer Spacer ---
                          const Spacer(),

                          // --- Footer Text ---
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.0,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Go back to login
                                  },
                                  child: const Text(
                                    "Login",
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