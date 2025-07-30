package com.example.wake_up_smile_and_learn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarma recibida, iniciando AlarmSoundService")
        val serviceIntent = Intent(context, AlarmSoundService::class.java)
        serviceIntent.putExtra("soundPath", intent.getStringExtra("soundPath"))
        serviceIntent.putExtra("alarmId", intent.getStringExtra("alarmId"))
        serviceIntent.putExtra("question", intent.getStringExtra("question"))
        serviceIntent.putExtra("options", intent.getStringArrayExtra("options"))
        serviceIntent.putExtra("correctOption", intent.getIntExtra("correctOption", 0))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
} 