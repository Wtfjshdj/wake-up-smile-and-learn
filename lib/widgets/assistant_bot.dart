import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/windows_tts_service.dart';

class AssistantBot extends StatefulWidget {
  final String userName;
  final String state; // 'idle', 'talking', 'happy', 'motivate', 'celebrate'
  final String? message;
  final bool autoSpeak;

  const AssistantBot({
    Key? key,
    required this.userName,
    this.state = 'idle',
    this.message,
    this.autoSpeak = true,
  }) : super(key: key);

  @override
  State<AssistantBot> createState() => _AssistantBotState();
}

class _AssistantBotState extends State<AssistantBot> {
  final WindowsTTSService _ttsService = WindowsTTSService();
  bool _isSpeaking = false;
  bool _audioError = false;
  String? _lastMessage;
  bool _lottieError = false;

  // URL de animación Lottie probada
  static const String _robotLottieUrl = 'https://assets2.lottiefiles.com/packages/lf20_4kx2q32n.json';

  @override
  void initState() {
    super.initState();
    if (widget.autoSpeak && widget.message != null) {
      _speak(widget.message!);
    }
  }

  @override
  void didUpdateWidget(AssistantBot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el mensaje cambió y autoSpeak está habilitado, hablar el nuevo mensaje
    if (widget.autoSpeak && 
        widget.message != null && 
        widget.message != _lastMessage) {
      _speak(widget.message!);
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      // Si ya está hablando, detener primero
      await _ttsService.stop();
      await Future.delayed(Duration(milliseconds: 200));
    }

    try {
      setState(() { 
        _isSpeaking = true; 
        _audioError = false; 
        _lastMessage = text;
      });
      
      await _ttsService.speak(text, rate: 0.3);
      
      if (mounted) {
        setState(() { _isSpeaking = false; });
      }
    } catch (e) {
      print('Error en _speak: $e');
      if (mounted) {
        setState(() { 
          _audioError = true; 
          _isSpeaking = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_audioError && widget.message != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              widget.message!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        Container(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              Lottie.network(
                _robotLottieUrl,
                repeat: true,
                onLoaded: (_) {
                  setState(() { _lottieError = false; });
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.android, size: 100, color: Colors.blueGrey);
                },
              ),
              if (_isSpeaking)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 