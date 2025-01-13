import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roboarmv2/splach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Account.dart';
import 'Logs.dart';
import 'Settings.dart';
import 'colors.dart';
import 'home.dart';
import 'main.dart';

bool success = false;
void main() {
  runApp(Bluetooth());
}

class Bluetooth extends StatefulWidget {
  Bluetooth({Key? key}) : super(key: key);

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  int _currentIndex = 2;

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
  TextEditingController _messageController = TextEditingController();
  static const MethodChannel _channel = MethodChannel('bluetooth_channel');
  static const EventChannel _eventChannel = EventChannel('bluetooth_event_channel');

  StreamSubscription? _streamSubscription;
  String _receivedData = "No Message!";


  String msg = "No Message!";



  Future<void> connectBluetooth() async {
    try {
      bool connectionSuccess = await _channel.invokeMethod('connectBluetooth');
      setState(() {
        success = connectionSuccess;
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
      setState(() {
        success = false;
      });
    }
  }


  Future<bool> writeData(String data) async {
    try {
      final bool success = await _channel.invokeMethod('writeData', {'message': data});
      print("Send from Flutter");
      return success;
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
      return false;
    }
  }

  // Future<String> readData() async {
  //   try {
  //     final String result = await _channel.invokeMethod('readData');
  //     return result;
  //   } on PlatformException catch (e) {
  //     print("Error: ${e.message}");
  //     return '';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _streamSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        _receivedData = event;
        print(_receivedData);
      });
    }, onError: (error) {
      print("Error receiving data: $error");
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  final User? user = supabase.auth.currentUser;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Bluetooth",
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
                  padding: const EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 20),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/roboarmlogo.png",
                        height: MediaQuery.of(context).size.height / 10,
                      ),
                      const SizedBox(width: 15),
                      const Text(
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
                        elevation: 1,
                        child: ListTile(
                          title: Text(
                            itemName[i],
                            style: const TextStyle(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  connectBluetooth();
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondryColor, width: 2.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: const Text(
                    "Connect Bluetooth",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 23),
              Text(success ? "Connection made" : "No connection", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: success ? Colors.green :  Colors.red)),
              const SizedBox(height: 20),
              Text(success ? "Connected to HC-05" : "", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),

            ],
          ),
        ),
      ),
    );
  }
}
