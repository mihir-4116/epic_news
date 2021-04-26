import 'package:flutter/material.dart';
// import 'package:news_app/views/home.dart';
//
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app/auth/HomePage.dart';
import 'package:news_app/auth/resetpassword.dart';
import 'package:news_app/auth/sign-up.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:news_app/views/home.dart';
import 'package:news_app/auth/log-in.dart';
import 'package:news_app/auth/start.dart';
import 'package:news_app/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SharedPreferences pref = await SharedPreferences.getInstance();
  // var email = pref.getString('email');
  // runApp(email == null ? SignUp() : MyApp());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'getMyNews',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        // home: HomePage(),
        home: HomePage1(),
        routes: <String, WidgetBuilder>{
          "Login": (BuildContext context) => Login(),
          "SignUp": (BuildContext context) => SignUp(),
          "start": (BuildContext context) => Start(),
          "home": (BuildContext context) => HomePage(),
          "reset": (BuildContext context) => ResetScreen(),
        });
  }
}
