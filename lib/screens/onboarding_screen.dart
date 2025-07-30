import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _selectedGoals = <String>[];
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Datos del onboarding
  String _name = '';
  int _age = 7;
  String _gender = 'Niño';
  String _selectedMusic = 'Música alegre';
  String _selectedAvatar = 'assets/avatars/default_avatar.png';
  String _rewardType = 'Estrellas';
  TimeOfDay _selectedWakeUpTime = const TimeOfDay(hour: 7, minute: 0);

  // Opciones disponibles
  final List<String> _musicOptions = <String>[
    'Música alegre',
    'Sonidos de naturaleza',
    'Melodía suave',
    'Mi música favorita',
  ];

  final List<Map<String, String>> _avatarOptions = <Map<String, String>>[
    <String, String>{'name': 'Avatar por defecto', 'path': 'assets/avatars/default_avatar.png'},
    <String, String>{'name': 'Avatar 1', 'path': 'assets/avatars/avatar1.png'},
    <String, String>{'name': 'Avatar 2', 'path': 'assets/avatars/avatar2.png'},
    <String, String>{'name': 'Avatar 3', 'path': 'assets/avatars/avatar3.png'},
    <String, String>{'name': 'Avatar 4', 'path': 'assets/avatars/avatar4.png'},
    <String, String>{'name': 'Avatar 5', 'path': 'assets/avatars/avatar5.png'},
    <String, String>{'name': 'Avatar 6', 'path': 'assets/avatars/avatar6.png'},
  ];

  final List<String> _rewardOptions = <String>[
    'Físicas (juguetes, dulces, etc.)',
    'Gamificadas (avatares, logros)',
    'Mixtas (ambas)',

  ];

  final List<String> _goalOptions = <String>[
    'Levantarme temprano',
    'Hacer ejercicio',
    'Leer libros',
    'Ayudar en casa',
    'Aprender inglés',
    'Ser más ordenado',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Stack(
        children: <Widget>[
          // Fondo con animación de Lottie según la pantalla actual
          _buildLottieBackground(),
          
          // Contenido principal (sin cambios)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.9), // Más opaco para mejor legibilidad
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  // Indicador de progreso
                  _buildProgressIndicator(),
                  
                  // Contenido principal
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        _buildWelcomePage(),
                        _buildNamePage(),
                        _buildAgePage(),
                        _buildGenderPage(),
                        _buildMusicPage(),
                        _buildAvatarPage(),
                        _buildRewardsPage(),
                        _buildGoalsPage(),
                        _buildWakeUpTimePage(),
                        _buildSummaryPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildNavigationArrows(),
        ],
      ),
    );

  Widget _buildLottieBackground() {
    // Fondo estático con sol y nubecitas estilo Lingokids para todas las pantallas
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.blue[300]!,
            Colors.blue[100]!,
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Sol centrado en la parte superior
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.yellow[400],
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.yellow[200]!.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.orange[600],
                  size: 60,
                ),
              ),
            ),
          ),
          // Nubes decorativas distribuidas
          Positioned(
            top: 120,
            left: 50,
            child: Container(
              width: 70,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 60,
            child: Container(
              width: 50,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 100,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: 130,
            right: 120,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Row(
        children: List.generate(10, (int index) {
          final bool isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );

  Widget _buildWelcomePage() => FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          margin: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Icono de bienvenida en lugar de la animación Lottie
              Icon(
                Icons.rocket_launch,
                size: 120,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),
              Text(
                '¡Bienvenido a\nWake Up, Smile and Learn!',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Vamos a crear tu perfil especial para que tengas la mejor experiencia',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );

  Widget _buildNamePage() => _buildQuestionPage(
      icon: Icons.person,
      title: '¿Cuál es tu nombre?',
      subtitle: 'Queremos conocerte mejor',
      child: TextField(
        onChanged: (String value) {
          setState(() {
            _name = value;
          });
        },
        style: GoogleFonts.nunito(fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Escribe tu nombre aquí',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );

  Widget _buildAgePage() => _buildQuestionPage(
      icon: Icons.cake,
      title: '¿Cuántos años tienes?',
      subtitle: 'Esto nos ayuda a personalizar tu experiencia',
      child: Column(
        children: <Widget>[
          Text(
            '$_age años',
            style: GoogleFonts.nunito(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _age.toDouble(),
            min: 5,
            max: 10,
            divisions: 5,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (double value) {
              setState(() {
                _age = value.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('5 años', style: GoogleFonts.nunito(fontSize: 14)),
              Text('10 años', style: GoogleFonts.nunito(fontSize: 14)),
            ],
          ),
        ],
      ),
    );

  Widget _buildGenderPage() => _buildQuestionPage(
      icon: Icons.favorite,
      title: '¿Qué estilo prefieres?',
      subtitle: 'Elige el que más te guste',
      child: Column(
        children: <Widget>[
          _buildOptionCard(
            'Niño',
            Icons.sports_soccer,
            Colors.blue,
            _gender == 'Niño',
            () => setState(() => _gender = 'Niño'),
          ),
          const SizedBox(height: 15),
          _buildOptionCard(
            'Niña',
            Icons.favorite,
            Colors.pink,
            _gender == 'Niña',
            () => setState(() => _gender = 'Niña'),
          ),
          const SizedBox(height: 15),
          _buildOptionCard(
            'Prefiero otro estilo',
            Icons.eco,
            Colors.green,
            _gender == 'Prefiero no decir',
            () => setState(() => _gender = 'Prefiero no decir'),
          ),
        ],
      ),
    );

  Widget _buildMusicPage() => _buildQuestionPage(
      icon: Icons.music_note,
      title: '¿Qué música te gusta para despertar?',
      subtitle: 'Elige tu sonido favorito',
      child: Column(
        children: _musicOptions.map((String music) =>
          _buildListOption(
            music,
            Icons.music_note,
            _selectedMusic == music,
            () => setState(() => _selectedMusic = music),
          ),
        ).toList(),
      ),
    );

  Widget _buildAvatarPage() => _buildQuestionPage(
      icon: Icons.face,
      title: '¿Qué avatar prefieres?',
      subtitle: 'Elige tu avatar favorito',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
        ),
        itemCount: _avatarOptions.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> avatar = _avatarOptions[index];
          final bool isSelected = _selectedAvatar == avatar['path'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAvatar = avatar['path']!;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                    ),
                    child: Icon(
                      Icons.face,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    avatar['name']!,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );

  Widget _buildRewardsPage() => _buildQuestionPage(
      icon: Icons.star,
      title: '¿Qué tipo de recompensas te gustan más?',
      subtitle: 'Elige lo que más te motiva',
      child: Column(
        children: _rewardOptions.map((String reward) =>
          _buildListOption(
            reward,
            Icons.star,
            _rewardType == reward,
            () => setState(() => _rewardType = reward),
          ),
        ).toList(),
      ),
    );

  Widget _buildGoalsPage() => _buildQuestionPage(
      icon: Icons.flag,
      title: '¿Qué metas quieres cumplir?',
      subtitle: 'Puedes elegir varias',
      child: Column(
        children: _goalOptions.map((String goal) =>
          _buildCheckboxOption(
            goal,
            _selectedGoals.contains(goal),
            (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedGoals.add(goal);
                } else {
                  _selectedGoals.remove(goal);
                }
              });
            },
          ),
        ).toList(),
      ),
    );

  Widget _buildWakeUpTimePage() => _buildQuestionPage(
      icon: Icons.access_time,
      title: '¿A qué hora te levantas usualmente?',
      subtitle: 'Esta será tu primera alarma',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _selectedWakeUpTime.format(context),
            style: GoogleFonts.nunito(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedWakeUpTime,
                builder: (BuildContext context, Widget? child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null && picked != _selectedWakeUpTime) {
                setState(() {
                  _selectedWakeUpTime = picked;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: Text(
              'Seleccionar Hora',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildSummaryPage() => _buildQuestionPage(
      icon: Icons.celebration,
      title: '¡Perfecto!',
      subtitle: 'Aquí está tu perfil personalizado',
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '¡Hola $_name!',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                _buildSummaryItem('Edad', '$_age años'),
                _buildSummaryItem('Estilo', _gender),
                _buildSummaryItem('Música', _selectedMusic),
                _buildSummaryItem('Avatar', _selectedAvatar),
                _buildSummaryItem('Recompensas', _rewardType),
                _buildSummaryItem('Hora de Despertar', _selectedWakeUpTime.format(context)),
                if (_selectedGoals.isNotEmpty)
                  _buildSummaryItem('Metas', _selectedGoals.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );

  Widget _buildQuestionPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) => FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          margin: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              // Icono y título
              Icon(
                icon,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Contenido específico
              Expanded(
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildOptionCard(String title, IconData icon, Color color, bool isSelected, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );

  Widget _buildListOption(String title, IconData icon, bool isSelected, VoidCallback onTap) => GestureDetector(
      onTap: () {
        onTap();
        // Reproducir sonido si es una opción de música
        if (title.contains('Música') || title.contains('Sonidos') || title.contains('Melodía')) {
          _playMusicSample(title);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(fontSize: 16),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );

  Widget _buildCheckboxOption(String title, bool isSelected, Function(bool?) onChanged) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        title: Text(
          title,
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        value: isSelected,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

  Widget _buildSummaryItem(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildNavigationArrows() => Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Flecha hacia atrás
            if (_currentPage > 0)
              FloatingActionButton(
                heroTag: 'back',
                onPressed: _previousPage,
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.arrow_back),
              )
            else
              const SizedBox(width: 56), // Espacio vacío para mantener simetría

            // Flecha hacia adelante o botón de finalizar
            FloatingActionButton(
              heroTag: 'forward',
              onPressed: _canAdvance() ? _nextPage : null,
              backgroundColor: _canAdvance()
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              foregroundColor: _canAdvance()
                  ? Colors.white
                  : Colors.grey[600],
              child: Icon(_currentPage == 9 ? Icons.check : Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );

  void _nextPage() {
    if (_currentPage < 9) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    } else if (_currentPage == 9) {
      // En la última página, finalizar el onboarding
      _finishOnboarding(context);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  bool _canAdvance() {
    switch (_currentPage) {
      case 0: // Welcome page - siempre puede avanzar
        return true;
      case 1: // Name page
        return _name.trim().isNotEmpty;
      case 2: // Age page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 3: // Gender page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 4: // Music page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 5: // Avatar page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 6: // Rewards page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 7: // Goals page - puede avanzar aunque no haya seleccionado nada
        return true;
      case 8: // Wake up time page - siempre puede avanzar (tiene valor por defecto)
        return true;
      case 9: // Summary page - puede finalizar
        return true;
      default:
        return false;
    }
  }

  Future<void> _finishOnboarding(BuildContext context) async {
    // Crear el nuevo perfil
    final UserProfile newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      age: _age,
      gender: _gender,
      interests: <String>[], // Puedes usar los intereses seleccionados
      favoriteMusic: _selectedMusic,
      wakeUpTime: _selectedWakeUpTime,
      avatarUrl: _selectedAvatar,
      isParentConfirmed: false,
      createdAt: DateTime.now(),
      preferences: <String, dynamic>{},
      englishLevel: 'beginner',
      favoriteSongs: <String>[],
      coins: 0,
      level: 1,
      experience: 0,
      achievements: <String>[],
      lastLogin: DateTime.now(),
    );
    await LocalStorageService().addProfile(newProfile);
    if (mounted) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (Route route) => false,
      );
    }
  }

  void _playMusicSample(String musicType) async {
    try {
      String audioPath = '';
      switch (musicType) {
        case 'Música alegre':
          audioPath = 'music/happy_wakeup.mp3';
          break;
        case 'Sonidos de naturaleza':
          audioPath = 'music/nature_sounds.mp3';
          break;
        case 'Melodía suave':
          audioPath = 'music/morning_melody.mp3';
          break;
        case 'Mi música favorita':
          audioPath = 'music/custom_song.mp3';
          break;
        default:
          audioPath = 'music/happy_wakeup.mp3';
      }
      
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }
} 