import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roboarmv2/ControlPage.dart';
import 'package:roboarmv2/AutoPage.dart';
import 'package:roboarmv2/HomeFragment.dart';
import 'package:roboarmv2/ManualPage.dart';
import 'package:roboarmv2/splach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Account.dart';
import 'Bluetooth.dart';
import 'Logs.dart';
import 'Settings.dart';
import 'colors.dart';
import 'main.dart';

void main() {
  runApp(const home());
}

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _HomeState();
}

class _HomeState extends State<home> {
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.bluetoothConnect,
    ].request();
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });
    if (statuses[Permission.bluetooth] == PermissionStatus.granted &&
        statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.locationWhenInUse] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted) {
      print("All permissions granted!");
    } else {
      print("Permissions not granted");
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  int _currentIndex = 0;

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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    HomeFragment(),
    ControlPage(),
    AutoPage(),
    ManualPage(),
  ];

  final User? user = supabase.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "RoboArm",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: secondryColor,
          centerTitle: true,
          actions: [
            Image.asset(
              "images/roboarmlogo.png",
              height: MediaQuery.of(context).size.height / 10,
            ),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: secondryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: secondryColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 27,),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_rounded, size: 27,),
                label: 'Control',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_mode_rounded, size: 27,),
                label: 'Auto',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.precision_manufacturing_rounded, size: 27,),
                label: 'Manual',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            selectedFontSize: 25,
            unselectedFontSize: 23,
            unselectedItemColor: secondryColor,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            onTap: _onItemTapped,
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
