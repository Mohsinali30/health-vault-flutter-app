import 'package:flutter/material.dart';

import 'AppColors.dart';

class ProfileCustomField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool readOnly;
  final  TextEditingController controll;

   const ProfileCustomField({
    super.key,
    required this.icon,
    required this.label,
    this.readOnly = false,
    required this.controll,
    // By default, profile fields are read-only
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding is managed by the parent, but a slight vertical margin is fine
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controll,
        readOnly: readOnly,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          // Floating Label (as seen in the image)
          labelText: label,
          labelStyle: const TextStyle(color: primaryGreen),

          // Icon on the left
          prefixIcon: Icon(icon, color: primaryGreen),

          // Styling the border to be rounded and outlined
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),

          // Focus border (when the user taps it)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: primaryGreen, width: 2.0),
          ),

          // Content padding adjustment
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }
}