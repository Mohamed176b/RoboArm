import 'dart:io';
import 'dart:math';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roboarmv2/splach.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;

Future<void> setFullScreen() async {
  double screenWidth = ui.window.physicalSize.width / ui.window.devicePixelRatio;
  double screenHeight = ui.window.physicalSize.height / ui.window.devicePixelRatio;
  double diagonalInches = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2)) / ui.window.devicePixelRatio;
  double ppi = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2)) / diagonalInches;
  await DesktopWindow.setWindowSize(Size(ui.window.physicalSize.width*ppi, ui.window.physicalSize.height*ppi - 40));
}

Future<void> main() async {
  if(Platform.isWindows){
    WidgetsFlutterBinding.ensureInitialized();
    await setFullScreen();
  }
  await Supabase.initialize(
    url: 'https://xditbsgzrqnyqrlrxset.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkaXRic2d6cnFueXFybHJ4c2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDgxOTI3NjcsImV4cCI6MjAyMzc2ODc2N30.uwQA5-Bt4T7Jv5QtjSdkvnOiCIesePoumYEGU3bUv64',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Splash(),
      theme: ThemeData(
        fontFamily: "cairo",
      ),
    );
  }
}
