import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm_model.dart';
import 'package:flutter/services.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  static bool shouldShowQuestion = false;
  static String? lastAlarmId;

  static const String alarmBoxName = 'alarms';
  static const platform = MethodChannel('wakeupsmile/alarm');

  late Box<Alarm> _alarmBox;

  Future<void> init() async {
    // Inicializar Hive
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AlarmAdapter());
    }
    _alarmBox = await Hive.openBox<Alarm>(alarmBoxName);
  }

  // Métodos CRUD para alarmas
  Future<void> addAlarm(Alarm alarm) async {
    final box = await Hive.openBox<Alarm>(alarmBoxName);
    await box.put(alarm.id, alarm);
    await scheduleAlarm(alarm);
  }

  Future<void> deleteAlarm(String id) async {
    await cancelAlarm(id);
    await _alarmBox.delete(id);
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await cancelAlarm(alarm.id); // Cancelar la alarma anterior
    await _alarmBox.put(alarm.id, alarm);
    await scheduleAlarm(alarm); // Programar la alarma actualizada
  }

  List<Alarm> getAlarms() {
    return _alarmBox.values.toList();
  }

  Future<Alarm?> getAlarmById(String id) async {
    final box = await Hive.openBox<Alarm>(alarmBoxName);
    return box.get(id);
  }

  // Programar alarma nativa con todos los datos relevantes
  Future<void> scheduleAlarm(Alarm alarm) async {
    try {
      await platform.invokeMethod('setAlarm', {
        'id': int.parse(alarm.id),
        'timeMillis': alarm.time.millisecondsSinceEpoch,
        'soundPath': alarm.soundFile,
        'question': alarm.question,
        'options': alarm.options,
        'correctOption': alarm.correctOption,
      });
    } catch (e) {
      print('Error al programar la alarma nativa: $e');
    }
  }

  // Cancelar alarma nativa
  Future<void> cancelAlarm(String id) async {
    try {
      await platform.invokeMethod('stopNativeAlarm', {
        'id': int.parse(id),
      });
    } catch (e) {
      print('Error al cancelar la alarma nativa: $e');
    }
  }

  // Handler para la acción de la notificación
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Cuando el usuario toca la notificación o el botón, activar el flag
    shouldShowQuestion = true;
    lastAlarmId = response.payload;
    // Aquí podrías usar navegación global si lo deseas, pero lo ideal es que HomeScreen consulte este flag
  }
} 