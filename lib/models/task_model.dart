class Task {
  final String id;
  final String title;
  final String description;
  final String englishQuestion;
  final List<String> options;
  final int correctAnswerIndex;
  final int coinsReward;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String category;
  final int difficulty; // 1-3 (fácil, medio, difícil)
  final String priority;
  final DateTime? deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.englishQuestion,
    required this.options,
    required this.correctAnswerIndex,
    required this.coinsReward,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.category,
    required this.difficulty,
    required this.priority,
    this.deadline,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'englishQuestion': englishQuestion,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'coinsReward': coinsReward,
        'isCompleted': isCompleted,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
        'category': category,
        'difficulty': difficulty,
        'priority': priority,
        'deadline': deadline?.millisecondsSinceEpoch,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        englishQuestion: map['englishQuestion'] as String,
        options: List<String>.from(map['options']),
        correctAnswerIndex: map['correctAnswerIndex'] as int,
        coinsReward: map['coinsReward'] as int,
        isCompleted: map['isCompleted'] as bool? ?? false,
        completedAt: map['completedAt'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
            : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        category: map['category'] as String? ?? 'general',
        difficulty: map['difficulty'] as int,
        priority: map['priority'] as String? ?? 'medium',
        deadline: map['deadline'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
            : null,
      );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? englishQuestion,
    List<String>? options,
    int? correctAnswerIndex,
    int? coinsReward,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    String? category,
    int? difficulty,
    String? priority,
    DateTime? deadline,
  }) => Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        englishQuestion: englishQuestion ?? this.englishQuestion,
        options: options ?? this.options,
        correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
        coinsReward: coinsReward ?? this.coinsReward,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        priority: priority ?? this.priority,
        deadline: deadline ?? this.deadline,
      );
} 