

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashService{

  void islogin(BuildContext context){

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if(user != null){
      Timer(Duration(seconds: 3), ()=> Navigator.pushNamed(context, 'home'));
    }
    else{
      Timer(Duration(seconds: 3), ()=>
          Navigator.pushNamed(context, 'Login'));

    }


  }


}