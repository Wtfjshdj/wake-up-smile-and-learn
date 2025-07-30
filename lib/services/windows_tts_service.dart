import 'package:flutter_tts/flutter_tts.dart';

class WindowsTTSService {
  static final WindowsTTSService _instance = WindowsTTSService._internal();
  factory WindowsTTSService() => _instance;
  WindowsTTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  Future<void> _init({double rate = 0.60}) async {
    if (_isInitialized) return;
    
    try {
      await _tts.setLanguage('es-MX');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      
      // Configurar callbacks para manejar el estado
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('Error TTS: $msg');
      });
      
      _isInitialized = true;
    } catch (e) {
      print('Error inicializando TTS: $e');
      _isInitialized = false;
    }
  }

  Future<void> speak(String text, {double rate = 0.45}) async {
    try {
      // Si ya está hablando, detener primero
      if (_isSpeaking) {
        await stop();
        // Pequeña pausa para asegurar que se detuvo completamente
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      await _init(rate: rate);
      await _tts.setSpeechRate(rate);
      await _tts.speak(text);
    } catch (e) {
      print('Error en speak: $e');
      _isSpeaking = false;
      // Reintentar inicialización en caso de error
      _isInitialized = false;
      throw e;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error deteniendo TTS: $e');
    }
  }

  bool get isSpeaking => _isSpeaking;

  void dispose() {
    _tts.stop();
    _isSpeaking = false;
    _isInitialized = false;
  }

  Future<void> printAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      print('Voces disponibles:');
      for (var voice in voices) {
        print(voice);
      }
    } catch (e) {
      print('Error obteniendo voces: $e');
    }
  }

  Future<void> setVoice(String voiceName) async {
    try {
      await _tts.setVoice({
        'name': voiceName,
        'locale': 'es-MX',
      });
    } catch (e) {
      print('Error configurando voz: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final voicesRaw = await Future.value(_tts.getVoices);
      if (voicesRaw is List) {
        return voicesRaw
            .where((v) => v is Map)
            .map((v) => Map<String, dynamic>.from(
                (v as Map).map((key, value) => MapEntry(key.toString(), value))))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo voces: $e');
      return [];
    }
  }

  // Método de prueba para diagnosticar problemas
  Future<bool> testTTS() async {
    try {
      print('🧪 Iniciando prueba de TTS...');
      
      // Verificar inicialización
      await _init();
      print('✅ TTS inicializado correctamente');
      
      // Obtener voces disponibles
      final voices = await getVoices();
      print('📢 Voces disponibles: ${voices.length}');
      for (var voice in voices) {
        print('  - ${voice['name']} (${voice['locale']})');
      }
      
      // Probar habla
      print('🗣️ Probando habla...');
      await speak('Hola, esto es una prueba del sistema de voz.');
      print('✅ Prueba de habla completada');
      
      return true;
    } catch (e) {
      print('❌ Error en prueba de TTS: $e');
      return false;
    }
  }
} 