import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/music_service.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> _alarms = [];
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctOption = 0;
  String _selectedSound = '';
  List<String> _availableSounds = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _loadAvailableSounds();
  }

  void _loadAlarms() {
    setState(() {
      _alarms = AlarmService().getAlarms();
    });
  }

  Future<void> _loadAvailableSounds() async {
    // Solo obtener los tracks de música del MusicService
    final musicService = MusicService();
    await musicService.initialize(); // Asegurar que se inicialice
    
    // Obtener todos los tracks de música (sistema y usuario)
    final allTracks = musicService.musicTracks;
    
    setState(() {
      _availableSounds = allTracks.map((track) => track.path).toList();
      if (_availableSounds.isNotEmpty) {
        _selectedSound = _availableSounds.first;
      }
    });
  }

  Future<void> _addAlarm() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await _showAlarmDialog(null, picked);
    }
  }

  Future<void> _showAlarmDialog(String? alarmId, TimeOfDay picked) async {
    final bool isEditing = alarmId != null;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, size: 48, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 12),
                      Text(
                        isEditing ? 'Editar alarma' : 'Configura tu alarma',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          labelText: 'Pregunta (en inglés)',
                          prefixIcon: const Icon(Icons.question_mark_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(4, (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextField(
                              controller: _optionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Opción  [200C${String.fromCharCode(65 + i)}',
                                prefixIcon: Icon(Icons.circle, color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Respuesta correcta:'),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _correctOption,
                            items: List.generate(4, (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(String.fromCharCode(65 + i)),
                                )),
                            onChanged: (v) {
                              setDialogState(() {
                                _correctOption = v!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sonido de alarma:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSound.isNotEmpty ? _selectedSound : null,
                                items: _availableSounds.map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.music_note, size: 20, color: Theme.of(context).primaryColor),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _getSoundDisplayName(s),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setDialogState(() {
                                      _selectedSound = v;
                                    });
                                  }
                                },
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                                dropdownColor: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (_selectedSound.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Seleccionado: ${_getSoundDisplayName(_selectedSound)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final question = _questionController.text.trim();
                                final options = _optionControllers.map((c) => c.text.trim()).toList();
                                if (question.isEmpty || options.any((o) => o.isEmpty)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Por favor, completa la pregunta y todas las opciones.'),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                  return;
                                }
                                final nowDate = DateTime.now();
                                final alarmTime = DateTime(nowDate.year, nowDate.month, nowDate.day, picked.hour, picked.minute);
                                
                                if (isEditing) {
                                  // Actualizar alarma existente
                                  final existingAlarm = _alarms.firstWhere((a) => a.id == alarmId);
                                  final updatedAlarm = Alarm(
                                    id: existingAlarm.id,
                                    time: alarmTime,
                                    repeat: existingAlarm.repeat,
                                    title: existingAlarm.title,
                                    active: existingAlarm.active,
                                    isActive: existingAlarm.isActive,
                                    question: question,
                                    options: options,
                                    correctOption: _correctOption,
                                    soundFile: _selectedSound,
                                  );
                                  await AlarmService().updateAlarm(updatedAlarm);
                                } else {
                                  // Crear nueva alarma
                                  final alarm = Alarm(
                                    id: (DateTime.now().millisecondsSinceEpoch % 2147483647).toString(),
                                    time: alarmTime,
                                    repeat: false,
                                    title: 'Alarma',
                                    active: true,
                                    isActive: true,
                                    question: question,
                                    options: options,
                                    correctOption: _correctOption,
                                    soundFile: _selectedSound,
                                  );
                                  await AlarmService().addAlarm(alarm);
                                }
                                
                                _questionController.clear();
                                for (final c in _optionControllers) c.clear();
                                setState(() {
                                  _correctOption = 0;
                                  _selectedSound = _availableSounds.first;
                                });
                                Navigator.pop(context);
                                _loadAlarms();
                                await Future.delayed(const Duration(milliseconds: 300));
                                if (mounted && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEditing ? '¡Alarma actualizada exitosamente!' : '¡Alarma guardada exitosamente!'),
                                      backgroundColor: Theme.of(context).primaryColor,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(isEditing ? Icons.edit_rounded : Icons.save_rounded),
                              label: Text(isEditing ? 'Actualizar' : 'Guardar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editAlarm(Alarm alarm) async {
    // Cargar los datos de la alarma en los controladores
    _questionController.text = alarm.question;
    for (int i = 0; i < _optionControllers.length; i++) {
      if (i < alarm.options.length) {
        _optionControllers[i].text = alarm.options[i];
      } else {
        _optionControllers[i].clear();
      }
    }
    _correctOption = alarm.correctOption;
    _selectedSound = alarm.soundFile ?? _availableSounds.first;

    final now = TimeOfDay.fromDateTime(alarm.time);
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      await _showAlarmDialog(alarm.id, picked);
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    await AlarmService().deleteAlarm(alarm.id);
    _loadAlarms();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarma eliminada'), backgroundColor: Colors.red),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  String _getSoundDisplayName(String soundPath) {
    // Buscar el track en MusicService para obtener el nombre real
    final musicService = MusicService();
    final track = musicService.musicTracks.firstWhere(
      (track) => track.path == soundPath,
      orElse: () => MusicTrack(
        id: 'unknown',
        title: soundPath.split('/').last.replaceAll('.mp3', ''),
        path: soundPath,
      ),
    );
    
    return track.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alarmas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 32),
            color: Theme.of(context).colorScheme.onPrimary,
            tooltip: 'Add Alarm',
            onPressed: _addAlarm,
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text('No hay alarmas aún', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text('¡Toca ➕ para crear una alarma!', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black45)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Text('🕒', style: TextStyle(fontSize: 24)),
                    ),
                    title: Text(
                      _formatTime(alarm.time),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: alarm.repeat
                        ? Text('Repetir diariamente', style: TextStyle(color: Theme.of(context).colorScheme.secondary))
                        : Text('Una sola vez', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                          tooltip: 'Editar',
                          onPressed: () => _editAlarm(alarm),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                          tooltip: 'Eliminar',
                          onPressed: () => _deleteAlarm(alarm),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAlarm,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Añadir alarma', style: TextStyle(fontSize: 18)),
      ),
    );
  }
} 