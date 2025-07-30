import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'dart:async';
import 'music_screen.dart';
import 'tasks_screen.dart';
import 'achievements_screen.dart';
import 'store_screen.dart';
import 'settings_screen.dart';
import 'parent_pin_screen.dart';
import '../widgets/assistant_bot.dart';
import '../services/local_storage_service.dart';
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/alarm_service.dart';
import '../models/alarm_model.dart';
import 'alarm_list_screen.dart';
import '../services/music_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _userProfile;
  bool _loading = true;
  bool _showAssistantMessage = false;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;
  bool _isProcessing = false;
  late Timer _timer;
  String? _botMessage;

  @override
  void initState() {
    super.initState();
    _resetAssistantSpokenFlag();
    _loadProfile();
    _checkAndSetAssistantMessage();
    _startTimer();
    _checkShowQuestionDialog();
  }

  Future<void> _resetAssistantSpokenFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('assistant_spoken_once');
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService().getActiveProfile();
    setState(() {
      _userProfile = profile;
      _loading = false;
    });
  }

  Future<void> _checkAndSetAssistantMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('assistant_spoken_once') ?? false;
    setState(() {
      _showAssistantMessage = !shown;
    });
    if (!shown) {
      await prefs.setBool('assistant_spoken_once', true);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // No longer checking for alarms here, as they are removed.
    });
  }

  void _checkShowQuestionDialog() async {
    if (AlarmService.shouldShowQuestion && AlarmService.lastAlarmId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final alarm = await AlarmService().getAlarmById(AlarmService.lastAlarmId!);
        if (alarm != null) {
          _showCustomQuestionDialog(alarm);
        }
        AlarmService.shouldShowQuestion = false;
        AlarmService.lastAlarmId = null;
      });
    }
  }

  void _showCustomQuestionDialog(Alarm alarm) {
    // Reproducir el sonido personalizado de la alarma
    MusicService().playAlarm(alarm.soundFile);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int? selected;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🧠 English Challenge!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(alarm.question, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ...List.generate(alarm.options.length, (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: selected == i ? Colors.blueAccent : Colors.blue,
                          ),
                          onPressed: selected == null
                              ? () {
                                  setState(() {
                                    selected = i;
                                  });
                                  Future.delayed(const Duration(milliseconds: 600), () {
                                    Navigator.pop(context);
                                    _handleAnswer(alarm, i);
                                  });
                                }
                              : null,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('${String.fromCharCode(65 + i)}. ${alarm.options[i]}', style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleAnswer(Alarm alarm, int selected) async {
    // Apagar el sonido de la alarma si está sonando
    await MusicService().stopAlarm();
    await AlarmService().cancelAlarm(alarm.id);
    setState(() {
      if (selected == alarm.correctOption) {
        _botMessage = '¡Excelente, sigue así!';
      } else {
        _botMessage = 'Equivocarse también es aprender, ¡ánimo!';
      }
    });
    // Mostrar el mensaje del bot
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤖 Bot'),
        content: Text(_botMessage ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '¡Buenos días!',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (String value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => const SettingsScreen()),
                );
              } else if (value == 'parent') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => const ParentPinScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                value: 'settings',
                child: Text('Configuración'),
              ),
              const PopupMenuItem(
                value: 'parent',
                child: Text('Modo Padres'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AlarmListScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade100,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('⏰', style: TextStyle(fontSize: 40)),
                      SizedBox(width: 16),
                      Text(
                        'Mis Alarmas',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Mensaje de bienvenida
                    Text(
                      '¡Es hora de despertar con una sonrisa!',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 350,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: <Widget>[
                          _buildActivityCard(
                            context,
                            'Tareas',
                            Icons.task,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => const TasksScreen()),
                            ),
                          ),
                          _buildActivityCard(
                            context,
                            'Música',
                            Icons.music_note,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => const MusicScreen()),
                            ),
                          ),
                          _buildActivityCard(
                            context,
                            'Tienda',
                            Icons.store,
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => const StoreScreen()),
                            ),
                          ),
                          _buildActivityCard(
                            context,
                            'Logros',
                            Icons.emoji_events,
                            Colors.amber,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (BuildContext context) => const AchievementsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_userProfile != null)
                      AssistantBot(
                        userName: _userProfile!.name ?? 'amigo',
                        message: '¡Hola ${_userProfile!.name ?? 'amigo'}! ¿Listo para comenzar tu día con una sonrisa y muchas ganas?',
                        state: 'talking',
                        autoSpeak: _showAssistantMessage,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
} 