import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roboarmv2/CustomDialog.dart';
import 'package:roboarmv2/UpdateName.dart';
import 'package:roboarmv2/UpdatePassword.dart';
import 'package:roboarmv2/splach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Bluetooth.dart';
import 'Logs.dart';
import 'Settings.dart';
import 'UpdateEmail.dart';
import 'colors.dart';
import 'home.dart';
import 'main.dart';

void main() {
  runApp(Account());
}

class Account extends StatefulWidget {
  @override
  State<Account> createState() => _MyAppState();
}

class _MyAppState extends State<Account> {
  int _currentIndex = 1;

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
            "Account",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: secondryColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => home()),
                      (Route<dynamic> route) => false,
                );
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: primaryColor,
                size: 30,
              ),
            )
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
        body: Center(
          child: Container(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: user!.appMetadata?["provider"] == "google"
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          user!.userMetadata?["picture"],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(
                        Icons.account_circle_outlined,
                        size: 120,
                        color: secondryColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: secondryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user!.appMetadata?["provider"] == "email"
                                    ? (user!.userMetadata != null ? user!.userMetadata!["username"] ?? "" : "")
                                    : user!.userMetadata!["full_name"],
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: secondryColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 15,),
                              Icon(Icons.arrow_forward_ios_rounded, size: 25, color: secondryColor,),
                            ],
                          ),
                        ),
                        onTap: () {
                          if(user!.appMetadata?["provider"] == "email"){
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => UpdateName()),
                            );
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: secondryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                user!.email.toString(),
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: secondryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 15,),
                            Icon(Icons.arrow_forward_ios_rounded, size: 25, color: secondryColor,),
                          ],
                        ),
                        onTap: () {
                          // if(user!.appMetadata?["provider"] == "email"){
                          //   Navigator.of(context).push(
                          //     MaterialPageRoute(builder: (context) => UpdateEmail()),
                          //   );
                          // }
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => UpdateEmail()),
                            );

                        },
                      ),
                    ),

                    SizedBox(height: 20),
                    user!.appMetadata?["provider"] == "email"
                        ? MaterialButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => UpdatePassword()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: secondryColor, width: 2.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: const Text(
                          "Change Password",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    )
                        : Container(),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(title: "Alert", content: "Click on your account information to change it.");
              },
            );
          },
          child: Icon(Icons.info_outline_rounded, color: primaryColor, size: 30,),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: secondryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
