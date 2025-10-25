import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;

  // Use the specific controller type for better type safety
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
  }) : super(key: key);

  // NOTE: The GlobalKey should typically be managed by the parent screen,
  // not the reusable field widget itself. We'll remove it for simplicity.
  // final _fromkey= GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Semi-transparent white background
        borderRadius: BorderRadius.circular(10.0),
      ),
      // We can wrap the TextFormField directly in the Container.
      // The parent screen should handle the overall Form widget and its key.
      child: TextFormField( // ⬅️ Change 1: Use TextFormField
        controller: controller, // Use the passed controller
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),

        // ⬅️ Change 2 & 3: Add the validator property here (inside TextFormField)
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your email or password.";
          }
          // Add more specific validation logic here if needed
          return null; // Return null if the input is valid
        },

        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hintText,
          // Customize error style to match your dark/green theme
          errorStyle: TextStyle(color: Colors.red.shade200),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
    );
  }
}