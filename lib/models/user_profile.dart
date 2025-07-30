import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String? gender;
  final List<String> interests;
  final String? favoriteMusic;
  final TimeOfDay wakeUpTime;
  final String? avatarUrl;
  final bool isParentConfirmed;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;
  final String englishLevel;
  final List<String> favoriteSongs;
  final int coins;
  final int level;
  final int experience;
  final List<String> achievements;
  final DateTime lastLogin;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    this.gender,
    required this.interests,
    this.favoriteMusic,
    required this.wakeUpTime,
    this.avatarUrl,
    required this.isParentConfirmed,
    required this.createdAt,
    required this.preferences,
    required this.englishLevel,
    required this.favoriteSongs,
    required this.coins,
    required this.level,
    required this.experience,
    required this.achievements,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'interests': interests,
        'favoriteMusic': favoriteMusic,
        'wakeUpTime': <String, int>{
          'hour': wakeUpTime.hour,
          'minute': wakeUpTime.minute,
        },
        'avatarUrl': avatarUrl,
        'isParentConfirmed': isParentConfirmed,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'preferences': preferences,
        'englishLevel': englishLevel,
        'favoriteSongs': favoriteSongs,
        'coins': coins,
        'level': level,
        'experience': experience,
        'achievements': achievements,
        'lastLogin': lastLogin.millisecondsSinceEpoch,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Manejar wakeUpTime de forma segura
    TimeOfDay wakeUpTime;
    if (map['wakeUpTime'] != null) {
      final Map<String, dynamic> wakeUpTimeMap = map['wakeUpTime'] as Map<String, dynamic>;
      wakeUpTime = TimeOfDay(
        hour: wakeUpTimeMap['hour'] as int,
        minute: wakeUpTimeMap['minute'] as int,
      );
    } else {
      // Valor por defecto si no hay wakeUpTime
      wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
    }

    return UserProfile(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        age: map['age'] as int? ?? 0,
        gender: map['gender'] as String?,
        interests: map['interests'] != null 
            ? List<String>.from(map['interests'])
            : <String>[],
        favoriteMusic: map['favoriteMusic'] as String?,
        wakeUpTime: wakeUpTime,
        avatarUrl: map['avatarUrl'] as String?,
        isParentConfirmed: map['isParentConfirmed'] as bool? ?? false,
        createdAt: map['createdAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
            : DateTime.now(),
        preferences: map['preferences'] as Map<String, dynamic>? ?? <String, dynamic>{},
        englishLevel: map['englishLevel'] as String? ?? 'beginner',
        favoriteSongs: map['favoriteSongs'] != null 
            ? List<String>.from(map['favoriteSongs'])
            : <String>[],
        coins: map['coins'] as int? ?? 0,
        level: map['level'] as int? ?? 1,
        experience: map['experience'] as int? ?? 0,
        achievements: map['achievements'] != null 
            ? List<String>.from(map['achievements'])
            : <String>[],
        lastLogin: map['lastLogin'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'] as int)
            : DateTime.now(),
      );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    List<String>? interests,
    String? favoriteMusic,
    TimeOfDay? wakeUpTime,
    String? avatarUrl,
    bool? isParentConfirmed,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
    String? englishLevel,
    List<String>? favoriteSongs,
    int? coins,
    int? level,
    int? experience,
    List<String>? achievements,
    DateTime? lastLogin,
  }) => UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        interests: interests ?? this.interests,
        favoriteMusic: favoriteMusic ?? this.favoriteMusic,
        wakeUpTime: wakeUpTime ?? this.wakeUpTime,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isParentConfirmed: isParentConfirmed ?? this.isParentConfirmed,
        createdAt: createdAt ?? this.createdAt,
        preferences: preferences ?? this.preferences,
        englishLevel: englishLevel ?? this.englishLevel,
        favoriteSongs: favoriteSongs ?? this.favoriteSongs,
        coins: coins ?? this.coins,
        level: level ?? this.level,
        experience: experience ?? this.experience,
        achievements: achievements ?? this.achievements,
        lastLogin: lastLogin ?? this.lastLogin,
      );

  bool get isYoungerGroup => age >= 5 && age <= 7;
  bool get isOlderGroup => age >= 8 && age <= 10;
} 