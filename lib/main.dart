import 'package:firebase_practice/views/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'View_view_Model/provider.dart';
import 'firebase_options.dart';
void main() async{
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await Supabase.initialize(
  url: 'https://tsbzfoicjroilxbfaasw.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzYnpmb2ljanJvaWx4YmZhYXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNDkxMDQsImV4cCI6MjA3NjkyNTEwNH0.J5IYK0_pUJwaeAFP1WIQIDH3w1PvHxlfikTx_TEn5Z8',
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: 
    [
      ChangeNotifierProvider(create: (_)=> Loadingstate()),
    ],
        child: Builder(builder: (BuildContext context) {
          return MaterialApp
            (
            title: 'Health Vault',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: SplashScreen(),
          );
        }
    ),);
        }
}


