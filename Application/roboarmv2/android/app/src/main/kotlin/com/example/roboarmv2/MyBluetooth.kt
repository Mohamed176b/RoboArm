package com.example.roboarmv2

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.content.ContentValues.TAG
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import java.io.IOException
import java.util.*
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel


class MyBluetooth(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private lateinit var btSocket: BluetoothSocket
    private val _myUUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb")
    private var _isConnected: Boolean = false
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())///////

    val isConnected: Boolean
        get() {
            _isConnected = this::btSocket.isInitialized && btSocket.isConnected
            return _isConnected
        }

    fun connect(): Boolean {
        bluetoothAdapter?.let { adapter ->
            val device = adapter.getRemoteDevice("98:D6:32:35:8F:DF")
            Toast.makeText(context, "Connecting...", Toast.LENGTH_SHORT).show()
            adapter.cancelDiscovery()

            try {
                btSocket = device.createRfcommSocketToServiceRecord(_myUUID)
                btSocket.connect()
                Toast.makeText(context, "Connection made.", Toast.LENGTH_SHORT).show()
                startListeningForData()
                return true
            } catch (e: IOException) {
                Log.e(TAG, "Connection error: ${e.message}")
                try {
                    btSocket.close()
                } catch (e2: IOException) {
                    Log.e(TAG, "Error closing socket: ${e2.message}")
                }
                Toast.makeText(context, "Socket creation or connection failed.", Toast.LENGTH_SHORT).show()
            }
        } ?: run {
            Toast.makeText(context, "Bluetooth is not available on this device.", Toast.LENGTH_SHORT).show()
        }
        return false
    }

    private fun startListeningForData() {
        Thread {
            try {
                val inStream = btSocket.inputStream
                val buffer = ByteArray(1024)
                var bytesRead: Int
                var accumulatedMessage = ""

                while (true) {
                    bytesRead = inStream.read(buffer)
                    if (bytesRead > 0) {
                        val readMessage = String(buffer, 0, bytesRead)
                        accumulatedMessage += readMessage

                        val endIndex = accumulatedMessage.indexOf('\n')
                        if (endIndex != -1) {
                            val completeMessage = accumulatedMessage.substring(0, endIndex).trim()
                            accumulatedMessage = accumulatedMessage.substring(endIndex + 1)

                            handler.post {
                                eventSink?.success(completeMessage)
                            }
                        }
                    }
                }
            } catch (e: IOException) {
                Log.e(TAG, "Error reading data: ${e.message}")
            }
        }.start()
    }
    fun setEventSink(eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    fun writeData(data: String): Boolean {
        if (!isConnected)
            return false
        var outStream = btSocket.outputStream
        try {
            outStream = btSocket.outputStream
        } catch (e: IOException) {
            return false
        }
        val msgBuffer = data.toByteArray()

        try {
            outStream.write(msgBuffer)
            print("Send from kotlin")

        } catch (e: IOException) {
            return false
        }
        return true
    }

    fun readData(): String {
        if (!isConnected)
            return ""
        var inStream = btSocket.inputStream
        try {
            inStream = btSocket.inputStream
        } catch (e: IOException) {
        }

        var s = ""

        try {
            while (inStream.available() > 0) {
                s += inStream.read().toChar()
            }
        } catch (e: IOException) {
        } finally {
            return s
        }
    }



}