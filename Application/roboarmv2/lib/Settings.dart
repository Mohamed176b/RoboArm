import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roboarmv2/splach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Account.dart';
import 'Bluetooth.dart';
import 'Logs.dart';
import 'colors.dart';
import 'home.dart';
import 'main.dart';

bool _switchCondition = true;
Future<void> setSwitch(bool state) async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('_switchCondition', state);
}

void main() {
  runApp(Settings());
}

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _MyAppState();
}

class _MyAppState extends State<Settings> {

  int _currentIndex = 4;

  final List<String> itemName = ["Home", "Account", "Bluetooth","Logs", "Settings"];

  final List<IconData> icons = [
    Icons.home,
    Icons.account_circle_outlined,
    Icons.bluetooth,
    Icons.code,
    Icons.settings,
  ];

  final List<Widget> pages = [
    home(),
    Account(),
    Bluetooth(),
    Logs(),
    Settings(),
  ];

  final User? user = supabase.auth.currentUser;



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: secondryColor,
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => home()),
                    (Route<dynamic> route) => false,
              );
            },
              icon: Icon(Icons.arrow_back_ios,
                color: primaryColor,
                size: 30,),)
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: secondryColor,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 20),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/roboarmlogo.png",
                        height: MediaQuery.of(context).size.height / 10,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "RoboArm",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(color: backgroundColor, height: 2),
                Expanded(
                  child: ListView.builder(
                    itemCount: itemName.length,
                    itemBuilder: (context, i) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: backgroundColor,
                        child: ListTile(
                          title: Text(
                            itemName[i],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: secondryColor,
                            ),
                          ),
                          leading: Icon(
                            icons[i],
                            color: primaryColor,
                            size: 30,
                          ),
                          onTap: () {
                            if (_currentIndex == i) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                    (Route<dynamic> route) => false,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => pages[i]),
                              );
                            }
                          },
                        ),
                        elevation: 1,
                      );
                    },
                  ),
                ),
                MaterialButton(
                  padding: EdgeInsets.only(bottom: 20),
                  onPressed: () async {
                    if(Platform.isAndroid){
                      if(user!.appMetadata?["provider"] == "google"){
                        GoogleSignIn().signOut();
                      }
                    }
                    await supabase.auth.signOut();
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('supabaseSessionToken');
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Splash()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: secondryColor, width: 2.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: Text(_switchCondition?'Auto':"Manual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),),
                        value: _switchCondition,
                        activeColor: secondryColor,
                        inactiveThumbColor: primaryColor,
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: secondryColor,
                        onChanged: (value) {
                          setState(() {
                            _switchCondition = value;
                            setSwitch(_switchCondition);

                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            );
          },
        ),
      ),
    );
  }
}

