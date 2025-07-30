import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  final String id;
  final String name;
  final String description;
  final String category; // "boy", "girl", "neutral"
  final bool isPremium;
  final String? previewImage;
  final Map<String, dynamic> colors;
  final Map<String, dynamic> fonts;

  AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isPremium = false,
    this.previewImage,
    required this.colors,
    required this.fonts,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isPremium': isPremium,
      'previewImage': previewImage,
      'colors': colors,
      'fonts': fonts,
    };

  factory AppTheme.fromMap(Map<String, dynamic> map) => AppTheme(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      isPremium: map['isPremium'] as bool? ?? false,
      previewImage: map['previewImage'] as String?,
      colors: Map<String, dynamic>.from(map['colors']),
      fonts: Map<String, dynamic>.from(map['fonts']),
    );

  ThemeData toThemeData() => ThemeData(
      primaryColor: Color(colors['primary'] as int),
      colorScheme: ColorScheme.light(
        primary: Color(colors['primary'] as int),
        secondary: Color(colors['secondary'] as int),
        surface: Color(colors['surface'] as int),
        onPrimary: Color(colors['onPrimary'] as int),
        onSecondary: Color(colors['onSecondary'] as int),
        onSurface: Color(colors['onSurface'] as int),
      ),
      scaffoldBackgroundColor: Color(colors['scaffoldBackground'] as int),
      textTheme: _getTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(colors['primary'] as int),
          foregroundColor: Color(colors['onPrimary'] as int),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        color: Color(colors['cardBackground'] as int),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(colors['primary'] as int)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(colors['primary'] as int).withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(colors['primary'] as int), width: 2),
        ),
        filled: true,
        fillColor: Color(colors['inputBackground'] as int),
      ),
    );

  TextTheme _getTextTheme() {
    final String fontFamily = fonts['family'] as String? ?? 'Nunito';
    
    return GoogleFonts.getTextTheme(fontFamily).copyWith(
      displayLarge: GoogleFonts.getFont(fontFamily).copyWith(
        fontSize: fonts['displayLarge']?['size']?.toDouble() ?? 32,
        fontWeight: FontWeight.values[fonts['displayLarge']?['weight'] ?? 7],
        color: Color(colors['displayText'] as int),
      ),
      displayMedium: GoogleFonts.getFont(fontFamily).copyWith(
        fontSize: fonts['displayMedium']?['size']?.toDouble() ?? 24,
        fontWeight: FontWeight.values[fonts['displayMedium']?['weight'] ?? 7],
        color: Color(colors['displayText'] as int),
      ),
      bodyLarge: GoogleFonts.getFont(fontFamily).copyWith(
        fontSize: fonts['bodyLarge']?['size']?.toDouble() ?? 16,
        fontWeight: FontWeight.values[fonts['bodyLarge']?['weight'] ?? 4],
        color: Color(colors['bodyText'] as int),
      ),
      bodyMedium: GoogleFonts.getFont(fontFamily).copyWith(
        fontSize: fonts['bodyMedium']?['size']?.toDouble() ?? 14,
        fontWeight: FontWeight.values[fonts['bodyMedium']?['weight'] ?? 4],
        color: Color(colors['bodyText'] as int),
      ),
    );
  }
}

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  List<AppTheme> _themes = <AppTheme>[];
  AppTheme? _currentTheme;
  String? _selectedThemeId;

  // Callbacks para la UI
  Function(AppTheme)? onThemeChanged;

  AppTheme? get currentTheme => _currentTheme;
  List<AppTheme> get themes => List.unmodifiable(_themes);
  List<AppTheme> get boyThemes => _themes.where((AppTheme theme) => theme.category == 'boy').toList();
  List<AppTheme> get girlThemes => _themes.where((AppTheme theme) => theme.category == 'girl').toList();
  List<AppTheme> get neutralThemes => _themes.where((AppTheme theme) => theme.category == 'neutral').toList();

  Future<void> initialize() async {
    await _loadThemes();
    await _loadSelectedTheme();
  }

  Future<void> _loadThemes() async {
    // Temas predefinidos
    _themes = <AppTheme>[
      // Temas para niños
      AppTheme(
        id: 'boy_1',
        name: 'Aventura Espacial',
        description: '¡Explora el universo con colores vibrantes!',
        category: 'boy',
        colors: <String, dynamic>{
          'primary': 0xFF2196F3,
          'secondary': 0xFFFF9800,
          'surface': 0xFFE3F2FD,
          'background': 0xFFF5F9FF,
          'scaffoldBackground': 0xFFF5F9FF,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFFFFFFFF,
          'onSurface': 0xFF1976D2,
          'onBackground': 0xFF1976D2,
          'displayText': 0xFF1565C0,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
      AppTheme(
        id: 'boy_2',
        name: 'Dragón Valiente',
        description: '¡Sé valiente como un dragón!',
        category: 'boy',
        colors: <String, dynamic>{
          'primary': 0xFFD32F2F,
          'secondary': 0xFFFFC107,
          'surface': 0xFFFFEBEE,
          'background': 0xFFFFF8E1,
          'scaffoldBackground': 0xFFFFF8E1,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFF000000,
          'onSurface': 0xFFC62828,
          'onBackground': 0xFFC62828,
          'displayText': 0xFFB71C1C,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
      
      // Temas para niñas
      AppTheme(
        id: 'girl_1',
        name: 'Princesa Mágica',
        description: '¡Vive en un mundo de magia y fantasía!',
        category: 'girl',
        colors: <String, dynamic>{
          'primary': 0xFFE91E63,
          'secondary': 0xFF9C27B0,
          'surface': 0xFFFCE4EC,
          'background': 0xFFFDF2F8,
          'scaffoldBackground': 0xFFFDF2F8,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFFFFFFFF,
          'onSurface': 0xFFC2185B,
          'onBackground': 0xFFC2185B,
          'displayText': 0xFFAD1457,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
      AppTheme(
        id: 'girl_2',
        name: 'Mariposa Brillante',
        description: '¡Vuela alto con colores brillantes!',
        category: 'girl',
        colors: <String, dynamic>{
          'primary': 0xFF00BCD4,
          'secondary': 0xFFFFEB3B,
          'surface': 0xFFE0F7FA,
          'background': 0xFFF0FDFF,
          'scaffoldBackground': 0xFFF0FDFF,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFF000000,
          'onSurface': 0xFF00838F,
          'onBackground': 0xFF00838F,
          'displayText': 0xFF006064,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
      
      // Temas neutros
      AppTheme(
        id: 'neutral_1',
        name: 'Naturaleza Verde',
        description: '¡Conecta con la naturaleza!',
        category: 'neutral',
        colors: <String, dynamic>{
          'primary': 0xFF4CAF50,
          'secondary': 0xFF8BC34A,
          'surface': 0xFFE8F5E8,
          'background': 0xFFF1F8E9,
          'scaffoldBackground': 0xFFF1F8E9,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFF000000,
          'onSurface': 0xFF2E7D32,
          'onBackground': 0xFF2E7D32,
          'displayText': 0xFF1B5E20,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
      AppTheme(
        id: 'neutral_2',
        name: 'Arcoíris Feliz',
        description: '¡Todos los colores del arcoíris!',
        category: 'neutral',
        colors: <String, dynamic>{
          'primary': 0xFF9C27B0,
          'secondary': 0xFFFF5722,
          'surface': 0xFFF3E5F5,
          'background': 0xFFFDF2F8,
          'scaffoldBackground': 0xFFFDF2F8,
          'onPrimary': 0xFFFFFFFF,
          'onSecondary': 0xFFFFFFFF,
          'onSurface': 0xFF7B1FA2,
          'onBackground': 0xFF7B1FA2,
          'displayText': 0xFF4A148C,
          'bodyText': 0xFF424242,
          'cardBackground': 0xFFFFFFFF,
          'inputBackground': 0xFFFFFFFF,
        },
        fonts: <String, dynamic>{
          'family': 'Nunito',
          'displayLarge': <String, int>{'size': 32, 'weight': 7},
          'displayMedium': <String, int>{'size': 24, 'weight': 7},
          'bodyLarge': <String, int>{'size': 16, 'weight': 4},
          'bodyMedium': <String, int>{'size': 14, 'weight': 4},
        },
      ),
    ];

    // Cargar temas personalizados guardados
    await _loadCustomThemes();
  }

  Future<void> _loadCustomThemes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> customThemesJson = prefs.getStringList('custom_themes') ?? <String>[];
    
    for (final String json in customThemesJson) {
      try {
        final AppTheme theme = AppTheme.fromMap(jsonDecode(json));
        _themes.add(theme);
      } catch (e) {
        debugPrint('Error loading custom theme: $e');
      }
    }
  }

  Future<void> _saveCustomThemes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<AppTheme> customThemes = _themes.where((AppTheme theme) => theme.id.startsWith('custom_')).toList();
    final List<String> themesJson = customThemes
        .map((AppTheme theme) => jsonEncode(theme.toMap()))
        .toList();
    
    await prefs.setStringList('custom_themes', themesJson);
  }

  Future<void> _loadSelectedTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedThemeId = prefs.getString('selected_theme_id');
    
    if (_selectedThemeId != null) {
      _currentTheme = _themes.firstWhere(
        (AppTheme theme) => theme.id == _selectedThemeId,
        orElse: () => _themes.first,
      );
    } else {
      _currentTheme = _themes.first;
    }
  }

  Future<void> selectTheme(String themeId) async {
    final AppTheme theme = _themes.firstWhere((AppTheme t) => t.id == themeId);
    _currentTheme = theme;
    _selectedThemeId = themeId;
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme_id', themeId);
    
    onThemeChanged?.call(theme);
  }

  Future<void> addCustomTheme(AppTheme theme) async {
    _themes.add(theme);
    await _saveCustomThemes();
  }

  Future<void> deleteCustomTheme(String themeId) async {
    if (themeId.startsWith('custom_')) {
      _themes.removeWhere((AppTheme theme) => theme.id == themeId);
      await _saveCustomThemes();
      
      // Si el tema eliminado era el seleccionado, cambiar al primero
      if (_selectedThemeId == themeId) {
        await selectTheme(_themes.first.id);
      }
    }
  }

  AppTheme? getThemeById(String themeId) {
    try {
      return _themes.firstWhere((AppTheme theme) => theme.id == themeId);
    } catch (e) {
      return null;
    }
  }
} 