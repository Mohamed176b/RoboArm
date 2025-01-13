package com.example.roboarmv2
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel



class MainActivity : FlutterActivity() {
    private val CHANNEL = "bluetooth_channel"
    private val EVENT_CHANNEL = "bluetooth_event_channel"
    var myBluetooth = MyBluetooth(this)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectBluetooth" -> {
                    val isConnected = myBluetooth.connect()

                    result.success(isConnected)
                }
                "writeData" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        val success = myBluetooth.writeData(message)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is null", null)
                    }
                }
                "readData" -> {
                    val data = myBluetooth.readData()
                    result.success(data)
                    val message = if (data.isEmpty()) "Connect the HC-05" else data
                    Toast.makeText(this, message, Toast.LENGTH_SHORT).show()

                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    myBluetooth.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    myBluetooth.setEventSink(null)
                }
            }
        )
    }
}

