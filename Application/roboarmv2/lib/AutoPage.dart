import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Bluetooth.dart';
import 'colors.dart';

class AutoPage extends StatefulWidget {
  @override
  State<AutoPage> createState() => _AutoPageState();
}

class _AutoPageState extends State<AutoPage> {
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
            'Automatic Moves',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 35),
          MaterialButton(
            onPressed: () {

              if(success){
                writeData("M");
              }else{
                null;
              }

            },
            child: Container(
              decoration: BoxDecoration(
                color: success? primaryColor: Colors.grey,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: secondryColor, width: 2.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.numbers_sharp,
                    color: Colors.white,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Move 1",
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
          const SizedBox(height: 30),
          MaterialButton(
            onPressed: () {
              if(success){
                writeData("N");
              }else{
                null;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: success? primaryColor: Colors.grey,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: secondryColor, width: 2.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.numbers_sharp,
                    color: Colors.white,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Move 2",
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
          const SizedBox(height: 30),
          Text(
            success
                ? _receivedData
                : "No connection",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: success ? Colors.green : Colors.red,
            ),
          )

        ],
      ),
    );
  }
}
