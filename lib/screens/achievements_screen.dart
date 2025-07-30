import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/local_storage_service.dart';
import '../models/user_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<Achievement> _achievements = const <Achievement>[
    Achievement(
      id: '1',
      title: 'Primera Alarma',
      description: 'Configuró su primera alarma',
      iconName: 'alarm',
      isUnlocked: true,
      unlockedAt: null,
    ),
    Achievement(
      id: '2',
      title: 'Músico',
      description: 'Reprodujo 10 canciones diferentes',
      iconName: 'music_note',
      isUnlocked: false,
    ),
    Achievement(
      id: '3',
      title: 'Estudiante Aplicado',
      description: 'Completó 5 tareas en un día',
      iconName: 'school',
      isUnlocked: false,
    ),
  ];

  UserProfile? _userProfile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService().getActiveProfile();
    setState(() {
      _userProfile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Logros',
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _buildAchievementsList(),
  );

  Widget _buildAchievementsList() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _achievements.length,
    itemBuilder: (BuildContext context, int index) {
      final Achievement achievement = _achievements[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: Icon(
            achievement.icon,
            color: achievement.isUnlocked ? Colors.orange : Colors.grey,
            size: 32,
          ),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(achievement.description),
              if (achievement.isUnlocked && achievement.unlockedAt != null)
                Text(
                  'Desbloqueado: ${_formatDate(achievement.unlockedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          trailing: achievement.isUnlocked
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.lock, color: Colors.grey),
        ),
      );
    },
  );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
} 