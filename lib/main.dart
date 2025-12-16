import 'package:firebase_practice/View_view_Model/AddEventProvider.dart';
import 'package:firebase_practice/View_view_Model/PrecripProvider.dart';
import 'package:firebase_practice/View_view_Model/bioProvider.dart';
import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:firebase_practice/tips_Screen.dart';
import 'package:firebase_practice/utiles/event_notification.dart';
import 'package:firebase_practice/views/AddEvents/EventScreen.dart';
import 'package:firebase_practice/views/HomeScreen/homescreen.dart';
import 'package:firebase_practice/views/Prescription/Precription_view.dart';
import 'package:firebase_practice/views/Profiles/ProfileSelectioScreen.dart';
import 'package:firebase_practice/views/Reminder_Screen/reminder_view.dart';
import 'package:firebase_practice/views/Upload_Docs/Viewallfiles.dart';
import 'package:firebase_practice/views/Upload_Docs/uploadScreen.dart';
import 'package:firebase_practice/views/auth/SignUp_Screen.dart';
import 'package:firebase_practice/views/auth/forgotPasswordScreen.dart';
import 'package:firebase_practice/views/auth/login_screen.dart';
import 'package:firebase_practice/views/auth/splash_screen.dart';
import 'package:firebase_practice/views/Profiles/profile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'View_view_Model/provider.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async{
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await Supabase.initialize(
    url: 'https://tsbzfoicjroilxbfaasw.supabase.co',
  anonKey: '',
);
//  Sirf ek line likhni hai init karne ke liye
  await NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: 
    [
      ChangeNotifierProvider(create: (_)=> Loadingstate()),
      ChangeNotifierProvider(create: (_)=> EventProvider()),
      ChangeNotifierProvider(create: (_)=> IsAdding()),
      ChangeNotifierProvider(create: (_)=> BioProvider()),
      ChangeNotifierProvider(create: (_)=> PrecripProvider()),
    ],
        child: Builder(builder: (BuildContext context) {
          return MaterialApp
            (
            title: 'Health Vault',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            initialRoute: 'SplashScreen',
            routes: {
              'SplashScreen': (context) =>  SplashScreen(),
              'Login': (context) =>  LoginScreen(),
              'Signup':(context) => SignUpScreen(),
              'home': (context) =>  HomeScreen(),
              'UploadScreen': (context) =>  UploadScreen(),
              'AllFile': (context) =>  Viewallfiles(),
              'ReminderView': (context) => ReminderView(),
              'Precription': (context) =>  PrecriptionView(),
              'AddEvent': (context) =>  EventScreen(),
              'UserProfile': (context) =>  MyProfileScreen(),
              'TipsView': (context) =>  ShowTipsScreen(),
              'ForgotScreen': (context)=> Forgotpasswordscreen(),
              'SelectProfileScreen': (context)=> Profileselectioscreen(),








            }
          );
        }
    ),);
        }
}


