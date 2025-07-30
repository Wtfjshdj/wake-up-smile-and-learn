import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../models/goal_model.dart';
import '../models/achievement_model.dart';

/// Service to handle local storage operations
class LocalStorageService {
  /// Key for storing user preferences
  static const String prefsKey = 'user_preferences';
  static const String profilesKey = 'user_profiles';
  static const String activeProfileKey = 'active_profile_id';

  /// Instance of SharedPreferences
  static late SharedPreferences _prefs;

  /// Initializes the local storage service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    final String jsonString = jsonEncode(prefs.toJson());
    await _prefs.setString(prefsKey, jsonString);
  }

  Future<UserPreferences?> loadUserPreferences() async {
    final String? jsonString = _prefs.getString(prefsKey);
    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return UserPreferences.fromJson(jsonMap);
  }

  /// Guarda la lista de perfiles
  Future<void> saveProfiles(List<UserProfile> profiles) async {
    final List<String> profilesJson = profiles.map((UserProfile p) => jsonEncode(p.toMap())).toList();
    await _prefs.setStringList(profilesKey, profilesJson);
  }

  /// Carga la lista de perfiles
  Future<List<UserProfile>> loadProfiles() async {
    final List<String> profilesJson = _prefs.getStringList(profilesKey) ?? <String>[];
    return profilesJson.map((String json) => UserProfile.fromMap(jsonDecode(json))).toList();
  }

  /// Guarda el ID del perfil activo
  Future<void> setActiveProfile(String profileId) async {
    await _prefs.setString(activeProfileKey, profileId);
  }

  /// Obtiene el ID del perfil activo
  Future<String?> getActiveProfileId() async => _prefs.getString(activeProfileKey);

  /// Elimina un perfil por ID
  Future<void> deleteProfile(String profileId) async {
    final List<UserProfile> profiles = await loadProfiles();
    profiles.removeWhere((UserProfile p) => p.id == profileId);
    await saveProfiles(profiles);
    // Si el eliminado era el activo, limpiar
    final String? activeId = await getActiveProfileId();
    if (activeId == profileId) {
      await _prefs.remove(activeProfileKey);
    }
  }

  /// Obtiene el perfil activo
  Future<UserProfile?> getActiveProfile() async {
    final List<UserProfile> profiles = await loadProfiles();
    final String? activeId = await getActiveProfileId();
    if (profiles.isEmpty) return null;
    return profiles.firstWhere(
      (UserProfile p) => p.id == activeId,
      orElse: () => profiles.first,
    );
  }

  /// Añade un nuevo perfil
  Future<void> addProfile(UserProfile profile) async {
    final List<UserProfile> profiles = await loadProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
    await setActiveProfile(profile.id);
  }

  /// Guarda la lista de metas para un perfil
  Future<void> saveGoalsForProfile(String profileId, List<Goal> goals) async {
    final List<String> goalsJson = goals.map((Goal g) => jsonEncode(g.toMap())).toList();
    await _prefs.setStringList('goals_$profileId', goalsJson);
  }

  /// Carga la lista de metas para un perfil
  Future<List<Goal>> loadGoalsForProfile(String profileId) async {
    final List<String> goalsJson = _prefs.getStringList('goals_$profileId') ?? <String>[];
    return goalsJson.map((String json) => Goal.fromMap(jsonDecode(json))).toList();
  }

  /// Añade una meta a un perfil
  Future<void> addGoalToProfile(String profileId, Goal goal) async {
    final List<Goal> goals = await loadGoalsForProfile(profileId);
    goals.add(goal);
    await saveGoalsForProfile(profileId, goals);
  }

  /// Actualiza una meta de un perfil
  Future<void> updateGoalForProfile(String profileId, Goal updatedGoal) async {
    final List<Goal> goals = await loadGoalsForProfile(profileId);
    final int idx = goals.indexWhere((Goal g) => g.id == updatedGoal.id);
    if (idx != -1) {
      goals[idx] = updatedGoal;
      await saveGoalsForProfile(profileId, goals);
    }
  }

  /// Elimina una meta de un perfil
  Future<void> deleteGoalFromProfile(String profileId, String goalId) async {
    final List<Goal> goals = await loadGoalsForProfile(profileId);
    goals.removeWhere((Goal g) => g.id == goalId);
    await saveGoalsForProfile(profileId, goals);
  }

  /// Guarda la lista de recompensas para un perfil
  Future<void> saveRewardsForProfile(String profileId, List<Achievement> rewards) async {
    final List<String> rewardsJson = rewards.map((Achievement r) => jsonEncode(r.toMap())).toList();
    await _prefs.setStringList('rewards_$profileId', rewardsJson);
  }

  /// Carga la lista de recompensas para un perfil
  Future<List<Achievement>> loadRewardsForProfile(String profileId) async {
    final List<String> rewardsJson = _prefs.getStringList('rewards_$profileId') ?? <String>[];
    return rewardsJson.map((String json) => Achievement.fromMap(jsonDecode(json))).toList();
  }

  /// Añade una recompensa a un perfil
  Future<void> addRewardToProfile(String profileId, Achievement reward) async {
    final List<Achievement> rewards = await loadRewardsForProfile(profileId);
    rewards.add(reward);
    await saveRewardsForProfile(profileId, rewards);
  }

  /// Actualiza una recompensa de un perfil
  Future<void> updateRewardForProfile(String profileId, Achievement updatedReward) async {
    final List<Achievement> rewards = await loadRewardsForProfile(profileId);
    final int idx = rewards.indexWhere((Achievement r) => r.id == updatedReward.id);
    if (idx != -1) {
      rewards[idx] = updatedReward;
      await saveRewardsForProfile(profileId, rewards);
    }
  }

  /// Elimina una recompensa de un perfil
  Future<void> deleteRewardFromProfile(String profileId, String rewardId) async {
    final List<Achievement> rewards = await loadRewardsForProfile(profileId);
    rewards.removeWhere((Achievement r) => r.id == rewardId);
    await saveRewardsForProfile(profileId, rewards);
  }
}