

import 'package:firebase_practice/firebase%20Services/splash_service.dart';
import 'package:flutter/material.dart';

import '../../utiles/AppColors.dart';

class SplashScreen extends StatefulWidget {
   SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashService splashservice= SplashService();
@override
  void initState() {
    super.initState();
    splashservice.islogin(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

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
    Center(child: Text("Health Vault",style: TextStyle(color: Colors.white,fontSize: 32),),
    ),
    ],)


    );
  }
}
