import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Bluetooth.dart';
import 'colors.dart';

Future<bool?> getSwitch() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? switchCondition = prefs.getBool('_switchCondition');
  return switchCondition;
}

class ControlPage extends StatefulWidget {
  @override
  State<ControlPage> createState() => _ControlPageState();
}


class _ControlPageState extends State<ControlPage> {

  bool _switchCondition = true;

  void _loadSwitchCondition() async {
    bool? condition = await getSwitch();
    setState(() {
      _switchCondition = condition ?? true;
    });
  }

  static const MethodChannel _channel = MethodChannel('bluetooth_channel');
  static const EventChannel _eventChannel = EventChannel('bluetooth_event_channel');

  StreamSubscription? _streamSubscription;
  TextEditingController _messageController = TextEditingController();
  String _receivedData = "No Message!";

  String msg = "No Message!";

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
    _loadSwitchCondition();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Control the arm',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: _switchCondition && success? () => writeData("P") : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _switchCondition && success? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondryColor, width: 2.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Play",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: _switchCondition && success? () => writeData("S") : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _switchCondition && success? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondryColor, width: 2.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Stop",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: _switchCondition && success? () => writeData("V") : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _switchCondition && success? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondryColor, width: 2.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: _switchCondition && success? () => writeData("R") : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _switchCondition && success? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondryColor, width: 2.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restart_alt,
                        color: Colors.white,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _switchCondition && success
                ? _receivedData
                : "No connection",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _switchCondition && success? Colors.green : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
