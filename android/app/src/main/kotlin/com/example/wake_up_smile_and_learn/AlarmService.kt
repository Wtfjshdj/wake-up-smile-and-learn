package com.example.wake_up_smile_and_learn

import android.app.Service
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.Vibrator
import android.os.VibrationEffect
import android.util.Log
import androidx.core.app.NotificationCompat
import android.net.Uri
import android.media.RingtoneManager
import android.app.PendingIntent
import org.json.JSONArray

class AlarmSoundService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val CHANNEL_ID = "alarm_sound_service"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val soundPath = intent?.getStringExtra("soundPath")
        val alarmId = intent?.getStringExtra("alarmId")
        val question = intent?.getStringExtra("question")
        val options = intent?.getStringArrayExtra("options")
        val correctOption = intent?.getIntExtra("correctOption", 0) ?: 0
        // Guardar estado de alarma activa en SharedPreferences
        val prefs = getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
        val optionsJson = if (options != null) JSONArray(options.toList()).toString() else null
        prefs.edit()
            .putBoolean("isAlarmActive", true)
            .putString("currentAlarmId", alarmId)
            .putString("currentSoundPath", soundPath)
            .putString("currentQuestion", question)
            .putString("currentOptionsJson", optionsJson)
            .putInt("currentCorrectOption", correctOption)
            .apply()
        startForeground(1, createNotification())
        playSound(soundPath)
        startVibration()
        // Lanzar la actividad de alarma educativa
        val alarmIntent = Intent(this, AlarmActivity::class.java)
        alarmIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        alarmIntent.putExtra("soundPath", soundPath)
        alarmIntent.putExtra("question", question)
        alarmIntent.putExtra("options", options)
        alarmIntent.putExtra("correctOption", correctOption)
        startActivity(alarmIntent)
        return START_STICKY
    }

    private fun createNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarma sonando",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
        // Intent para abrir AlarmActivity directamente con los datos de la alarma
        val intent = Intent(this, AlarmActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        // Obtener los datos del intent original del servicio
        val originalIntent = getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
        val soundPath = originalIntent.getString("currentSoundPath", "")
        val question = originalIntent.getString("currentQuestion", "¿?")
        val optionsJson = originalIntent.getString("currentOptionsJson", null)
        val options = if (optionsJson != null) {
            val jsonArray = JSONArray(optionsJson)
            Array(jsonArray.length()) { i -> jsonArray.getString(i) }
        } else {
            arrayOf("A", "B", "C", "D")
        }
        val correctOption = originalIntent.getInt("currentCorrectOption", 0)
        
        intent.putExtra("soundPath", soundPath)
        intent.putExtra("question", question)
        intent.putExtra("options", options)
        intent.putExtra("correctOption", correctOption)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("¡Hora de despertar!")
            .setContentText("Toca para responder la pregunta y apagar la alarma")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(false)
            .setFullScreenIntent(pendingIntent, true)
            .build()
    }

    private fun playSound(soundPath: String?) {
        try {
            if (soundPath != null && soundPath.isNotEmpty()) {
                Log.d("AlarmSoundService", "Intentando reproducir sonido: $soundPath")
                
                if (soundPath.startsWith("assets/")) {
                    // Para archivos de assets, usar AssetFileDescriptor
                    val assetManager = assets
                    val assetFileDescriptor = assetManager.openFd(soundPath)
                    mediaPlayer = MediaPlayer().apply {
                        setDataSource(assetFileDescriptor.fileDescriptor, assetFileDescriptor.startOffset, assetFileDescriptor.declaredLength)
                        setVolume(1.0f, 1.0f)
                        isLooping = true
                        prepare()
                        start()
                    }
                    assetFileDescriptor.close()
                } else {
                    // Para archivos del usuario (rutas de archivo)
                    mediaPlayer = MediaPlayer().apply {
                        setDataSource(soundPath)
                        setVolume(1.0f, 1.0f)
                        isLooping = true
                        prepare()
                        start()
                    }
                }
                Log.d("AlarmSoundService", "Sonido personalizado reproducido")
            } else {
                throw Exception("Ruta de sonido vacía")
            }
        } catch (e: Exception) {
            Log.e("AlarmSoundService", "Error reproduciendo sonido personalizado: $e. Usando sonido por defecto.")
            try {
                val alarmUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(this@AlarmSoundService, alarmUri)
                    setVolume(1.0f, 1.0f)
                    isLooping = true
                    prepare()
                    start()
                }
                Log.d("AlarmSoundService", "Sonido por defecto reproducido")
            } catch (ex: Exception) {
                Log.e("AlarmSoundService", "Error reproduciendo sonido por defecto: $ex")
            }
        }
    }

    private fun startVibration() {
        try {
            vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            val pattern = longArrayOf(0, 1000, 500, 2000)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                vibrator?.vibrate(pattern, 0)
            }
            Log.d("AlarmSoundService", "Vibración activada")
        } catch (e: Exception) {
            Log.e("AlarmSoundService", "Error activando vibración: $e")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.stop()
        mediaPlayer?.release()
        vibrator?.cancel()
        // (Eliminado) No limpiar SharedPreferences aquí, solo cuando Flutter lo ordene
    }

    override fun onBind(intent: Intent?): IBinder? = null
} 