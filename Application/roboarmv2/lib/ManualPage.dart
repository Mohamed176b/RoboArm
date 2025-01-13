import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roboarmv2/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bluetooth.dart';
Future<bool> getSwitch() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? switchCondition = prefs.getBool('_switchCondition');
  return switchCondition ?? true;
}

class ManualPage extends StatefulWidget {
  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  bool _switchCondition = true; // Initial default value

  void _loadSwitchCondition() async {
    bool condition = await getSwitch();
    setState(() {
      _switchCondition = condition;
    });
  }
  double slider1 = 20;
  double slider2 = 90;
  double slider3 = 0;
  double slider4 = 90;
  double slider5 = 0;
  double slider6 = 120;

  String slider1S = "";
  String slider2S = "";
  String slider3S = "";
  String slider4S = "";
  String slider5S = "";
  String slider6S = "";

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Manual',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildSliderRow('Waist', slider1, 20, 180, 32, (value) {
              setState(() {
                slider1 = value;
                slider1S = "s1" + slider1.toString();
                writeData(slider1S);
                print(slider1S);
              });
            }, success && _switchCondition == false),
            const SizedBox(height: 25),
            buildSliderRow('Shoulder', slider2, 90, 150, 12, (value) {
              setState(() {
                slider2 = value;
                slider2S = "s2" + slider2.toString();
                writeData(slider2S);
                print(slider2S);
              });
            }, success && _switchCondition == false),
            const SizedBox(height: 25),
            buildSliderRow('Elbow', slider3, 0, 90, 18, (value) {
              setState(() {
                slider3 = value;
                slider3S = "s3" + slider3.toString();
                writeData(slider3S);
                print(slider3S);
              });
            }, success && _switchCondition == false),
            const SizedBox(height: 25),
            buildSliderRow('Wrist Roll', slider4, 90, 180, 18, (value) {
              setState(() {
                slider4 = value;
                slider4S = "s4" + slider4.toString();
                writeData(slider4S);
                print(slider4S);
              });
            }, success && _switchCondition == false),
            const SizedBox(height: 25),
            buildSliderRow('Wrist Pitch', slider5, 0, 180, 36, (value) {
              setState(() {
                slider5 = value;
                slider5S = "s5" + slider5.toString();
                writeData(slider5S);
                print(slider5S);
              });
            }, success && _switchCondition == false),
            const SizedBox(height: 25),
            buildSliderRow('Grip', slider6, 120, 180, 12, (value) {
              setState(() {
                slider6 = value;
                slider6S = "s6" + slider6.toString();
                writeData(slider6S);
                print(slider6S);
              });
            }, success && _switchCondition == false),
            buildActionButtonRow(),
            const SizedBox(height: 30),
            Text(
              success && _switchCondition == false
                  ? _receivedData
                  : "No connection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: success ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSliderRow(String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged, bool isEnabled) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              height: 50,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: secondryColor,
                  trackHeight: 10.0,
                  thumbColor: Colors.amberAccent,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
                  tickMarkShape: RoundSliderTickMarkShape(),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  inactiveTickMarkColor: primaryColor,
                  valueIndicatorColor: primaryColor,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: value.round().toString(),
                  onChanged: isEnabled ? onChanged : null, // Disable the slider if isEnabled is false
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildActionButtonRow() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildMaterialButton(Icons.play_arrow, "Play", "P"),
            buildMaterialButton(Icons.stop, "Stop", "S"),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildMaterialButton(Icons.save, "Save", "V"),
            buildMaterialButton(Icons.restart_alt, "Reset", "R"),
          ],
        ),
      ],
    );
  }

  Widget buildMaterialButton(IconData icon, String label, String command) {
    return MaterialButton(
      onPressed: success ? () => writeData(command) : null,
      child: Container(
        decoration: BoxDecoration(
          color: success ? primaryColor : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: secondryColor, width: 2.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}