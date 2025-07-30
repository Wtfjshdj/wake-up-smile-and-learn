package com.example.wake_up_smile_and_learn

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wakeupsmile/alarm"

    companion object {
        var alarmActivityInstance: AlarmActivity? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAlarm" -> {
                    val millis = call.argument<Long>("timeMillis") ?: return@setMethodCallHandler
                    val soundPath = call.argument<String>("soundPath") ?: ""
                    val question = call.argument<String>("question") ?: "¿?"
                    val options = call.argument<List<String>>("options") ?: listOf("A", "B", "C", "D")
                    val correctOption = call.argument<Int>("correctOption") ?: 0
                    setNativeAlarm(millis, soundPath, question, options, correctOption)
                    result.success(true)
                }
                "stopNativeAlarm" -> {
                    // Detener el Service nativo que reproduce la alarma
                    val intent = Intent(this, AlarmSoundService::class.java)
                    stopService(intent)
                    // Limpiar estado de alarma activa en SharedPreferences
                    val prefs = getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
                    prefs.edit()
                        .putBoolean("isAlarmActive", false)
                        .remove("currentAlarmId")
                        .apply()
                    // También cerrar AlarmActivity si está abierta (por compatibilidad)
                    alarmActivityInstance?.runOnUiThread {
                        alarmActivityInstance?.finish()
                    }
                    result.success(true)
                }
                "getNativeAlarmState" -> {
                    val prefs = getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
                    val isActive = prefs.getBoolean("isAlarmActive", false)
                    val alarmId = prefs.getString("currentAlarmId", null)
                    val resultMap = HashMap<String, Any?>()
                    resultMap["isAlarmActive"] = isActive
                    resultMap["currentAlarmId"] = alarmId
                    result.success(resultMap)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setNativeAlarm(timeMillis: Long, soundPath: String, question: String, options: List<String>, correctOption: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        intent.putExtra("soundPath", soundPath)
        intent.putExtra("question", question)
        intent.putExtra("options", options.toTypedArray())
        intent.putExtra("correctOption", correctOption)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent)
        }
    }
}
