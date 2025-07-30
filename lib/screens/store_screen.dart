import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/theme_service.dart';
import '../widgets/theme_card.dart';
import '../services/local_storage_service.dart';
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ThemeService _themeService = ThemeService();
  List<dynamic> _themes = <dynamic>[];
  String _selectedCategory = 'all';
  bool _isLoading = true;
  UserProfile? _userProfile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _loadProfile();
  }

  Future<void> _loadThemes() async {
    await _themeService.initialize();
    setState(() {
      _themes = _themeService.themes;
      _isLoading = false;
    });
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService().getActiveProfile();
    setState(() {
      _userProfile = profile;
      _loading = false;
    });
  }

  List<dynamic> get _filteredThemes {
    if (_selectedCategory == 'all') return _themes;
    return _themes.where((theme) => theme.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Tienda de Temas',
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: <Widget>[
              _buildCategoryFilter(),
              Expanded(
                child: _filteredThemes.isEmpty 
                    ? _buildEmptyState() 
                    : _buildThemesGrid(),
              ),
            ],
          ),
  );

  Widget _buildLoadingState() => const Center(
    child: CircularProgressIndicator(),
  );

  Widget _buildCategoryFilter() => Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _buildCategoryChip('all', 'Todos'),
            const SizedBox(width: 8),
            _buildCategoryChip('boy', 'Niños'),
            const SizedBox(width: 8),
            _buildCategoryChip('girl', 'Niñas'),
            const SizedBox(width: 8),
            _buildCategoryChip('neutral', 'Neutros'),
          ],
        ),
      ),
    );

  Widget _buildCategoryChip(String category, String label) {
    final bool isSelected = _selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Lottie.asset(
            'assets/animations/welcome.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay temas disponibles',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Intenta con otra categoría',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildThemesGrid() => GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredThemes.length,
      itemBuilder: (BuildContext context, int index) {
        final theme = _filteredThemes[index];
        return ThemeCard(
          theme: theme,
          isSelected: _themeService.currentTheme?.id == theme.id,
          onSelect: () => _selectTheme(theme.id),
        );
      },
    );

  Future<void> _selectTheme(String themeId) async {
    await _themeService.selectTheme(themeId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tema aplicado correctamente'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }
} 