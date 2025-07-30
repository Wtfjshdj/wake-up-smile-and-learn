import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    this.category = 'general',
  });

  IconData get icon => iconFromName(iconName);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
        'category': category,
      };

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        iconName: map['iconName'] as String,
        isUnlocked: map['isUnlocked'] as bool? ?? false,
        unlockedAt: map['unlockedAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'] as int)
            : null,
        category: map['category'] as String? ?? 'general',
      );

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? category,
  }) => Achievement(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        category: category ?? this.category,
      );
}

// Utilidad para mapear nombre a IconData
IconData iconFromName(String name) {
  switch (name) {
    case 'alarm':
      return Icons.alarm;
    case 'music_note':
      return Icons.music_note;
    case 'school':
      return Icons.school;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'park':
      return Icons.park;
    case 'movie':
      return Icons.movie;
    case 'toys':
      return Icons.toys;
    case 'star':
      return Icons.star;
    default:
      return Icons.emoji_events;
  }
} 