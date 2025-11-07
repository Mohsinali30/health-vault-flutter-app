import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

// 1. Define App Colors and Text Styles for consistency


// Decoration for all pages to ensure consistent styling and layout
final pageDecoration = PageDecoration(
  titleTextStyle: TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: textColor,
  ),
  bodyTextStyle: TextStyle(
    fontSize: 16.0,
    color: textColor.withOpacity(0.8),
  ),
  bodyPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
  imagePadding: EdgeInsets.zero,
  pageColor: Colors.white,
  // Align content better, often centered or aligned to the top/middle
  contentMargin: const EdgeInsets.only(top: 30),
);


class ShowTipsScreen extends StatelessWidget {
  const ShowTipsScreen({super.key});

  List<PageViewModel> getpages() {
    return [
      PageViewModel(
        title: "Simple & Actionable Health Management Tips",
        // Using a Placeholder for the image or ensuring the image size is controlled
        image: Center(child: Image.asset('assets/intro.png', height: 250,width: double.infinity,)),
        body: "Let's explore key habits to maximize your health vault's value and stay proactive about your well-being.",
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Review Records Quarterly",
        image: Center(child: Image.asset('assets/intro.png', height: 250)),
        body: "Even if you feel fine, spend 15 minutes reviewing your last three months of lab reports, prescriptions, and visit summaries stored in the Vault. Understanding your trends is key to early detection.",
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Set Medication Reminders Immediately",
        image: Center(child: Image.asset('assets/intro.png', height: 250)),
        body:
        "As soon as you upload a new prescription, immediately set a reminder or alarm on your phone for dosage times. Consistency is vital for efficacy.",
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Doctor Visit Cheat Sheet",
        image: Center(child: Image.asset('assets/intro.png', height: 250)),
        body:
        "Before your appointment, use the app to quickly pull up your last lab result and your current medication list. This saves time and ensures your doctor has accurate information.",
        decoration: pageDecoration,
      ),
    ];
  }

  // Define the common style for navigation buttons
  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
    );
  }

  Widget _buildBackButton() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: primaryGreen.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Icon(Icons.arrow_back_ios_new_rounded, color: primaryGreen.withOpacity(0.7)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: getpages(),

        // 2. Custom Navigation Widgets (Next/Back/Done)
        showNextButton: true,
        showBackButton: true,
        showDoneButton: true, // You generally need a 'Done' button on the last page

        next: _buildNextButton(),
        back: _buildBackButton(),
        done: Text(
            "Let's Go!",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 18)
        ),

        // Add a callback for when the 'Done' button is pressed
        onDone: () {
           Navigator.pop(context);
        },

        // 3. Customize the Indicator Dots
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          color: Colors.grey.shade300,
          activeColor: primaryGreen,
        ),

        // 4. Customizing the bottom control area padding
        baseBtnStyle: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ),
    );
  }
}