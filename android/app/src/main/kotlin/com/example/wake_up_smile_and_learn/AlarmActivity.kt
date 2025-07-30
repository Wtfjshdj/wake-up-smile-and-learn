package com.example.wake_up_smile_and_learn

import android.app.Activity
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Vibrator
import android.os.VibrationEffect
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.content.Context
import android.content.Intent
import android.util.Log
import android.os.Build
import android.widget.Toast
import android.media.RingtoneManager
import android.net.Uri
import android.app.AlertDialog
import android.view.animation.AnimationUtils
import android.view.animation.Animation
import android.view.View
import android.os.Handler

class AlarmActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MainActivity.alarmActivityInstance = this
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_FULLSCREEN)
        setContentView(R.layout.activity_alarm)

        val soundPath = intent.getStringExtra("soundPath")
        val question = intent.getStringExtra("question") ?: "¿?"
        val options = intent.getStringArrayExtra("options") ?: arrayOf("A", "B", "C", "D")
        val correctOption = intent.getIntExtra("correctOption", 0)
        
        Log.d("AlarmActivity", "Datos recibidos:")
        Log.d("AlarmActivity", "Question: $question")
        Log.d("AlarmActivity", "Options: ${options.joinToString(", ")}")
        Log.d("AlarmActivity", "CorrectOption: $correctOption")
        Log.d("AlarmActivity", "SoundPath: $soundPath")

        val textView = findViewById<TextView>(R.id.alarm_message)
        textView.text = "¡Es hora de despertar!"
        val questionView = findViewById<TextView>(R.id.alarm_question)
        questionView.text = question
        val buttons = listOf(
            findViewById<Button>(R.id.option_a),
            findViewById<Button>(R.id.option_b),
            findViewById<Button>(R.id.option_c),
            findViewById<Button>(R.id.option_d)
        )
        
        // Cargar animación de pulsación
        val pulseAnimation = AnimationUtils.loadAnimation(this, android.R.anim.fade_in)
        
        for (i in buttons.indices) {
            if (i < options.size) {
                buttons[i].text = "${'A' + i}. ${options[i]}"
                buttons[i].isEnabled = true
                buttons[i].visibility = View.VISIBLE
                Log.d("AlarmActivity", "Configurando botón $i: ${buttons[i].text}")
                
                // Agregar animación de pulsación al hacer clic
                buttons[i].setOnClickListener {
                    it.startAnimation(pulseAnimation)
                    if (i == correctOption) {
                        // Respuesta correcta - animación de éxito
                        buttons[i].setBackgroundColor(0xFF4CAF50.toInt())
                        buttons[i].text = "✅ ${buttons[i].text}"
                        
                        // Detener alarma después de un breve delay
                        Handler().postDelayed({
                            try {
                                // Detener el servicio de alarma
                                val serviceIntent = Intent(this, AlarmSoundService::class.java)
                                stopService(serviceIntent)
                                
                                // Mostrar diálogo de éxito con animación
                                val successDialog = AlertDialog.Builder(this)
                                    .setTitle("🎉 ¡Correcto!")
                                    .setMessage("¡Excelente, lo has logrado!")
                                    .setPositiveButton("OK") { _, _ -> finish() }
                                    .setCancelable(false)
                                    .create()
                                
                                successDialog.show()
                                successDialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
                            } catch (e: Exception) {
                                Log.e("AlarmActivity", "Error al detener alarma: $e")
                                finish()
                            }
                        }, 500)
                    } else {
                        // Respuesta incorrecta - animación de error
                        buttons[i].setBackgroundColor(0xFFF44336.toInt())
                        buttons[i].text = "❌ ${buttons[i].text}"
                        
                        // Restaurar después de un delay
                        Handler().postDelayed({
                            buttons[i].setBackgroundColor(0xFFFF8A80.toInt())
                            buttons[i].text = "${'A' + i}. ${options[i]}"
                        }, 1000)
                        
                        // Mostrar mensaje motivacional
                        val errorDialog = AlertDialog.Builder(this)
                            .setTitle("💪 ¡Sigue intentando!")
                            .setMessage("Equivocarse también es aprender, ¡Ánimo!")
                            .setPositiveButton("OK", null)
                            .create()
                        
                        errorDialog.show()
                        errorDialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
                    }
                }
            } else {
                buttons[i].isEnabled = false
                buttons[i].visibility = View.GONE
            }
        }

        // El sonido ya se está reproduciendo en AlarmSoundService, no necesitamos duplicarlo aquí
        Log.d("AlarmActivity", "Sonido ya reproducido por AlarmSoundService")

        // La vibración ya se está activando en AlarmSoundService, no necesitamos duplicarla aquí
        Log.d("AlarmActivity", "Vibración ya activada por AlarmSoundService")

        // Botón para detener la alarma (eliminado)
        // val stopButton = findViewById<Button>(R.id.stop_alarm_button)
        // stopButton.setOnClickListener {
        //     mediaPlayer?.stop()
        //     mediaPlayer?.release()
        //     vibrator?.cancel()
        //     finish()
        // }
    }

    override fun onDestroy() {
        super.onDestroy()
        MainActivity.alarmActivityInstance = null
    }
} 