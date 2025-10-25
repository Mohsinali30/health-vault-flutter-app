
import 'package:flutter/material.dart';

class VerifyCode extends StatefulWidget {
 final String verficationId;
   VerifyCode({required this.verficationId});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        appBar: AppBar(
          title: Text("Verify Code"),
        ),
        body: Column(children: [
          
        ],),
      );
  }
}
