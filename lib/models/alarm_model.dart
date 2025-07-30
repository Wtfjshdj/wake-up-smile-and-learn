import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  bool repeat;

  @HiveField(3)
  String? title;

  @HiveField(4)
  bool active;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  // NUEVOS CAMPOS
  @HiveField(7)
  String question;

  @HiveField(8)
  List<String> options;

  @HiveField(9)
  int correctOption;

  @HiveField(10)
  String soundFile;

  Alarm({
    required this.id,
    required this.time,
    this.repeat = false,
    this.title,
    this.active = true,
    this.isActive = true,
    DateTime? createdAt,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.soundFile,
  }) : createdAt = createdAt ?? DateTime.now();
} 