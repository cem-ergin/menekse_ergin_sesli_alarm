package com.example.menekse_ergin

import android.content.Intent
import android.net.Uri
import android.provider.AlarmClock
import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread.
            // TODO
            if (call.method == "getBatteryLevel") {
                print("kafayi yicem yicem yciem yicem yceim ")
                val hour = call.argument<Int>("hour")
                val minute = call.argument<Int>("minute")
                val audioPath = call.argument<String>("audioPath")
                Log.d("audioPath",audioPath)

                //print("neden audio pathi yazmiyor $audioPath")
                setAlarm(hour!!, minute!!, audioPath!!)
                val batteryLevel = 90
                if (batteryLevel != -1) {
                  result.success(batteryLevel)
                } else {
                  result.error("UNAVAILABLE", "Battery level not available.", null)
                }
              } else {
                result.notImplemented()
              }
          }
        }

    private fun setAlarm(hour: Int, minute: Int, audioPath: String ){
        val uri = Uri.fromFile(File(audioPath))
        Log.d("my uri",uri.toString())
        val intent = Intent(AlarmClock.ACTION_SET_ALARM)
        intent.putExtra(AlarmClock.EXTRA_HOUR, hour)
        intent.putExtra(AlarmClock.EXTRA_MINUTES, minute)
        intent.putExtra(AlarmClock.EXTRA_RINGTONE,audioPath)
        //intent.putExtra(AlarmClock.EXTRA_RINGTONE,uri)
        startActivity(intent)
    }

}
