class Goal {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String unit; // "minutos", "veces", "días", etc.
  final int coinsReward;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? deadline;
  final String category;
  final bool isRecurring; // Si se repite diariamente, semanalmente, etc.
  final String? recurrenceType; // "daily", "weekly", "monthly"
  final String? reward;
  final String difficulty;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    required this.coinsReward,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.deadline,
    required this.category,
    this.isRecurring = false,
    this.recurrenceType,
    this.reward,
    this.difficulty = 'medium',
  });

  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'isCompleted': isCompleted,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
        'reward': reward,
        'difficulty': difficulty,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        category: map['category'] as String,
        targetValue: (map['targetValue'] as num).toInt(),
        currentValue: (map['currentValue'] as num).toInt(),
        unit: map['unit'] as String,
        coinsReward: map['coinsReward'] as int? ?? 0,
        isCompleted: map['isCompleted'] as bool? ?? false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        completedAt: map['completedAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
            : null,
        reward: map['reward'] as String?,
        difficulty: map['difficulty'] as String? ?? 'medium',
      );

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? targetValue,
    int? currentValue,
    String? unit,
    int? coinsReward,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? reward,
    String? difficulty,
  }) => Goal(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        targetValue: targetValue ?? this.targetValue,
        currentValue: currentValue ?? this.currentValue,
        unit: unit ?? this.unit,
        coinsReward: coinsReward ?? this.coinsReward,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        reward: reward ?? this.reward,
        difficulty: difficulty ?? this.difficulty,
      );
} 