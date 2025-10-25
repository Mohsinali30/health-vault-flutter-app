

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/views/HomeScreen/homescreen.dart';
import 'package:firebase_practice/views/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashService{

  void islogin(BuildContext context){

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if(user != null){
      Timer(Duration(seconds: 3), ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())));
    }
    else{
      Timer(Duration(seconds: 3), ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())));

    }


  }


}