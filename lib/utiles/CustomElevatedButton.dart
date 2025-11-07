import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  // Required properties
  final String text;
  final VoidCallback onPressed;

  // Optional styling properties
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets padding;
  final double borderRadius;
  final double elevation;
  final TextStyle textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    // Set default values using your common app style
    this.backgroundColor = primaryGreen, // Change to your primaryGreen
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = 22.0,
    this.elevation = 2.0,
    this.textStyle = const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,

        elevation: elevation,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        // Apply the custom text style
        textStyle: textStyle,
      ),
      child: Text(text),
    );
  }
}