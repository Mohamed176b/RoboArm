import 'package:flutter/material.dart';
import 'package:roboarmv2/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  checkSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? supabaseSessionToken = prefs.getString('supabaseSessionToken');

    await Future.delayed(const Duration(milliseconds: 2000));

    if (supabaseSessionToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "images/roboarmlogo.png",
              ),
              const Text(
                "RoboArm",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
