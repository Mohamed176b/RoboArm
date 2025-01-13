import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roboarmv2/splach.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Account.dart';
import 'Bluetooth.dart';
import 'Settings.dart';
import 'colors.dart';
import 'home.dart';
import 'main.dart';

void main() {
  runApp(Logs());
}

class Logs extends StatefulWidget {
  @override
  State<Logs> createState() => _MyAppState();
}

class _MyAppState extends State<Logs> {
  int _currentIndex = 3;
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

  static const MethodChannel _channel = MethodChannel('bluetooth_channel');
  static const EventChannel _eventChannel = EventChannel('bluetooth_event_channel');

  StreamSubscription? _streamSubscription;
  TextEditingController _messageController = TextEditingController();
  String _receivedData = "No Message!";
  List<Map<String, dynamic>> _receivedDataList = [];

  String msg = "No Message!";

  final ScrollController _scrollController = ScrollController();

  Future<void> connectBluetooth() async {
    try {
      await _channel.invokeMethod('connectBluetooth');
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
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

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        // Add received data with timestamp to the list
        _receivedDataList.add({
          'data': event,
          'timestamp': DateTime.now(), // Current timestamp
        });
        print(event);
        _scrollToBottom();
      });
    }, onError: (error) {
      print("Error receiving data: $error");
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Logs",
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
          body: success? ListView.builder(
            controller: _scrollController,
            itemCount: _receivedDataList.length,
            itemBuilder: (context, index) {
              // Extract data and timestamp
              final receivedData = _receivedDataList[index]['data'];
              final timestamp = _receivedDataList[index]['timestamp'] as DateTime;
              // Format timestamp
              final formattedTime = '${timestamp.year}-${_twoDigits(timestamp.month)}-${_twoDigits(timestamp.day)} ${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}:${_twoDigits(timestamp.second)}';
              return Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(receivedData.substring(2), style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Received at: $formattedTime'),
                ),
              );
            },
          ) : Center(
            child: Text("No connection",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          )
      ),
    );
  }
}
