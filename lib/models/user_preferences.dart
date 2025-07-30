/// Model class for user preferences.
class UserPreferences {
  /// Creates a new instance of [UserPreferences].
  UserPreferences({
    String? name,
    String? ageGroup,
    String? gender,
    String? englishLevel,
    List<String> interests = const <String>[],
    List<String> favoriteSongs = const <String>[],
    String? selectedTheme,
    String? selectedColorScheme,
    String? selectedFontSize,
  })  : name = name,
        ageGroup = ageGroup,
        gender = gender,
        englishLevel = englishLevel,
        interests = interests,
        favoriteSongs = favoriteSongs,
        selectedTheme = selectedTheme,
        selectedColorScheme = selectedColorScheme,
        selectedFontSize = selectedFontSize;

  /// The user's name.
  final String? name;
  
  /// The user's age group.
  final String? ageGroup;
  
  /// The user's gender.
  final String? gender;
  
  /// The user's English level.
  final String? englishLevel;

  /// The user's interests.
  final List<String> interests;

  /// The user's favorite songs.
  final List<String> favoriteSongs;

  /// The user's selected theme.
  final String? selectedTheme;

  /// The user's selected color scheme.
  final String? selectedColorScheme;

  /// The user's selected font size.
  final String? selectedFontSize;

  /// Converts preferences to JSON format.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'ageGroup': ageGroup,
        'gender': gender,
        'englishLevel': englishLevel,
        'interests': interests,
        'favoriteSongs': favoriteSongs,
        'selectedTheme': selectedTheme,
        'selectedColorScheme': selectedColorScheme,
        'selectedFontSize': selectedFontSize,
      };

  /// Creates preferences from JSON data.
  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        name: json['name'] as String?,
        ageGroup: json['ageGroup'] as String?,
        gender: json['gender'] as String?,
        englishLevel: json['englishLevel'] as String?,
        interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? <String>[],
        favoriteSongs: (json['favoriteSongs'] as List<dynamic>?)?.cast<String>() ?? <String>[],
        selectedTheme: json['selectedTheme'] as String?,
        selectedColorScheme: json['selectedColorScheme'] as String?,
        selectedFontSize: json['selectedFontSize'] as String?,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'ageGroup': ageGroup,
        'gender': gender,
        'englishLevel': englishLevel,
        'interests': interests,
        'favoriteSongs': favoriteSongs,
        'selectedTheme': selectedTheme,
        'selectedColorScheme': selectedColorScheme,
        'selectedFontSize': selectedFontSize,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        name: map['name'] as String?,
        ageGroup: map['ageGroup'] as String?,
        gender: map['gender'] as String?,
        englishLevel: map['englishLevel'] as String?,
        interests: map['interests'] != null 
            ? List<String>.from(map['interests'])
            : <String>[],
        favoriteSongs: map['favoriteSongs'] != null 
            ? List<String>.from(map['favoriteSongs'])
            : <String>[],
        selectedTheme: map['selectedTheme'] as String?,
        selectedColorScheme: map['selectedColorScheme'] as String?,
        selectedFontSize: map['selectedFontSize'] as String?,
      );
}
