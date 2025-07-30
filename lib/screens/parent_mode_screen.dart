import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wake_up_smile_and_learn/models/alarm_model.dart';
import 'package:wake_up_smile_and_learn/models/user_profile.dart';
import '../services/local_storage_service.dart';
import 'auth_screen.dart';
import '../models/goal_model.dart';
import '../models/achievement_model.dart';
import '../services/alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/parent_pin_service.dart';

class ParentModeScreen extends StatefulWidget {
  const ParentModeScreen({Key? key}) : super(key: key);

  @override
  State<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends State<ParentModeScreen> {
  int _selectedSection = 0;
  List<Goal> _goals = <Goal>[];
  String? _profileId;
  bool _loadingGoals = true;
  List<Achievement> _rewards = <Achievement>[];
  bool _loadingRewards = true;
  int _completedGoals = 0;
  int _totalGoals = 0;
  int _rewardsUnlocked = 0;
  int _totalRewards = 0;
  double _sleepHoursWeek = 0;
  bool _loadingStats = true;
  bool _nightModeActive = false;
  TimeOfDay? _nightStart;
  TimeOfDay? _nightEnd;

  @override
  void initState() {
    super.initState();
    _loadProfileAndGoals();
    _loadRewards();
    _loadStats();
    _loadNightPrefs();
  }

  Future<void> _loadProfileAndGoals() async {
    final UserProfile? profile = await LocalStorageService().getActiveProfile();
    if (profile != null) {
      final List<Goal> goals = await LocalStorageService().loadGoalsForProfile(profile.id);
      setState(() {
        _profileId = profile.id;
        _goals = goals;
        _loadingGoals = false;
      });
    }
  }

  Future<void> _loadRewards() async {
    if (_profileId == null) {
      setState(() { _loadingRewards = false; });
      return;
    }
    final List<Achievement> rewards = await LocalStorageService().loadRewardsForProfile(_profileId!);
    setState(() {
      _rewards = rewards;
      _loadingRewards = false;
    });
  }

  Future<void> _loadStats() async {
    setState(() { _loadingStats = true; });
    // Metas
    _completedGoals = _goals.where((Goal g) => g.isCompleted).length;
    _totalGoals = _goals.length;
    // Recompensas
    _rewardsUnlocked = _rewards.where((Achievement r) => r.isUnlocked).length;
    _totalRewards = _rewards.length;
    // Alarmas (horas de sueño)
    final List<Alarm> alarms = AlarmService().getAlarms();
    final DateTime now = DateTime.now();
    final DateTime weekAgo = now.subtract(const Duration(days: 7));
    // Suponiendo que cada alarma completada representa una noche de sueño de 8h
    final int alarmsThisWeek = alarms.where((Alarm a) => a.isActive == false && a.createdAt.isAfter(weekAgo)).length;
    _sleepHoursWeek = alarmsThisWeek * 8.0;
    setState(() { _loadingStats = false; });
  }

  Future<void> _loadNightPrefs() async {
    if (_profileId == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _nightModeActive = prefs.getBool('nightmode_${_profileId!}') ?? false;
    final String? start = prefs.getString('nightstart_${_profileId!}');
    final String? end = prefs.getString('nightend_${_profileId!}');
    if (start != null) {
      final List<String> parts = start.split(':');
      _nightStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (end != null) {
      final List<String> parts = end.split(':');
      _nightEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    setState(() {});
  }

  Future<void> _setNightMode(bool value) async {
    if (_profileId == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nightmode_${_profileId!}', value);
    setState(() { _nightModeActive = value; });
  }

  Future<void> _setNightSchedule(TimeOfDay start, TimeOfDay end) async {
    if (_profileId == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nightstart_${_profileId!}', '${start.hour}:${start.minute}');
    await prefs.setString('nightend_${_profileId!}', '${end.hour}:${end.minute}');
    setState(() { _nightStart = start; _nightEnd = end; });
  }

  Future<void> _pickNightSchedule() async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: _nightStart ?? const TimeOfDay(hour: 21, minute: 0),
      helpText: 'Selecciona hora de inicio del modo noche',
    );
    if (start == null) return;
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: _nightEnd ?? const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Selecciona hora de fin del modo noche',
    );
    if (end == null) return;
    await _setNightSchedule(start, end);
  }

  Future<void> _addGoalDialog() async {
    if (_profileId == null) return;
    final Goal? newGoal = await showDialog<Goal>(
      context: context,
      builder: (BuildContext ctx) => const _GoalDialog(),
    );
    if (newGoal != null) {
      await LocalStorageService().addGoalToProfile(_profileId!, newGoal);
      await _loadProfileAndGoals();
    }
  }

  Future<void> _editGoalDialog(Goal goal) async {
    if (_profileId == null) return;
    final Goal? updatedGoal = await showDialog<Goal>(
      context: context,
      builder: (BuildContext ctx) => _GoalDialog(goal: goal),
    );
    if (updatedGoal != null) {
      await LocalStorageService().updateGoalForProfile(_profileId!, updatedGoal);
      await _loadProfileAndGoals();
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    if (_profileId == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Seguro que quieres eliminar la meta "${goal.title}"?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await LocalStorageService().deleteGoalFromProfile(_profileId!, goal.id);
      await _loadProfileAndGoals();
    }
  }

  Future<void> _addQuickGoal(String title, IconData icon) async {
    if (_profileId == null) return;
    final Goal newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: '',
      targetValue: 1,
      currentValue: 0,
      unit: 'veces',
      coinsReward: 1,
      isCompleted: false,
      createdAt: DateTime.now(),
      category: 'hábitos',
      isRecurring: true,
      recurrenceType: 'daily',
      reward: null,
      difficulty: 'easy',
    );
    await LocalStorageService().addGoalToProfile(_profileId!, newGoal);
    await _loadProfileAndGoals();
  }

  Future<void> _addRewardDialog() async {
    if (_profileId == null) return;
    final Achievement? newReward = await showDialog<Achievement>(
      context: context,
      builder: (BuildContext ctx) => const _RewardDialog(),
    );
    if (newReward != null) {
      await LocalStorageService().addRewardToProfile(_profileId!, newReward);
      await _loadRewards();
    }
  }

  Future<void> _editRewardDialog(Achievement reward) async {
    if (_profileId == null) return;
    final Achievement? updatedReward = await showDialog<Achievement>(
      context: context,
      builder: (BuildContext ctx) => _RewardDialog(reward: reward),
    );
    if (updatedReward != null) {
      await LocalStorageService().updateRewardForProfile(_profileId!, updatedReward);
      await _loadRewards();
    }
  }

  Future<void> _deleteReward(Achievement reward) async {
    if (_profileId == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Eliminar recompensa'),
        content: Text('¿Seguro que quieres eliminar la recompensa "${reward.title}"?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await LocalStorageService().deleteRewardFromProfile(_profileId!, reward.id);
      await _loadRewards();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          'Modo Padres',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.lock_reset),
            tooltip: 'Cambiar PIN',
            onPressed: _onChangePin,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión/eliminar cuenta',
            onPressed: _onLogout,
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedSection,
            onDestinationSelected: (int i) => setState(() => _selectedSection = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[100],
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Supervisión'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag),
                label: Text('Metas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.card_giftcard),
                label: Text('Recompensas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.palette),
                label: Text('Interfaz'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.nightlight_round),
                label: Text('Modo noche'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildSection(_selectedSection),
            ),
          ),
        ],
      ),
    );

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return _buildStatsSection();
      case 1:
        return _buildGoalsSection();
      case 2:
        return _buildRewardsSection();
      case 3:
        return _buildInterfaceSection();
      case 4:
        return _buildNightModeSection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStatsSection() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: <Widget>[
        _sectionTitle('Progreso del niño/a'),
        _statCard('Metas completadas', '$_completedGoals de $_totalGoals', Icons.check_circle, Colors.green),
        _statCard('Horas de sueño (última semana)', '${_sleepHoursWeek.toStringAsFixed(1)} h', Icons.bed, Colors.blue),
        _statCard('Recompensas ganadas', '$_rewardsUnlocked de $_totalRewards', Icons.card_giftcard, Colors.amber),
        // Puedes añadir más estadísticas aquí
      ],
    );
  }

  Widget _buildGoalsSection() {
    if (_loadingGoals) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: <Widget>[
        _sectionTitle('Gestión de metas'),
        ..._goals.map((Goal goal) => Card(
          child: ListTile(
            leading: Icon(Icons.flag, color: goal.isCompleted ? Colors.green : Colors.blue),
            title: Text(goal.title),
            subtitle: Text(goal.description.isNotEmpty ? goal.description : 'Sin descripción'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editGoalDialog(goal)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteGoal(goal)),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Añadir meta personalizada'),
          onPressed: _addGoalDialog,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            ActionChip(
              avatar: const Icon(Icons.bed, size: 18),
              label: const Text('Tender la cama'),
              onPressed: () => _addQuickGoal('Tender la cama', Icons.bed),
            ),
            ActionChip(
              avatar: const Icon(Icons.brush, size: 18),
              label: const Text('Cepillarse'),
              onPressed: () => _addQuickGoal('Cepillarse', Icons.brush),
            ),
            ActionChip(
              avatar: const Icon(Icons.checkroom, size: 18),
              label: const Text('Alistar uniforme'),
              onPressed: () => _addQuickGoal('Alistar uniforme', Icons.checkroom),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardsSection() {
    if (_loadingRewards) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: <Widget>[
        _sectionTitle('Recompensas configurables'),
        ..._rewards.map((Achievement reward) => Card(
          child: ListTile(
            leading: Icon(Icons.card_giftcard, color: Colors.amber),
            title: Text(reward.title),
            subtitle: Text(reward.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editRewardDialog(reward)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteReward(reward)),
              ],
            ),
          ),
        )),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Añadir recompensa'),
          onPressed: _addRewardDialog,
        ),
      ],
    );
  }

  Widget _buildInterfaceSection() {
    // Aquí deberías conectar con tu modelo de temas/interfaz
    return ListView(
      children: <Widget>[
        _sectionTitle('Configurar interfaces disponibles'),
        SwitchListTile(
          title: const Text('Permitir personalización de interfaz'),
          value: true,
          onChanged: (bool v) {},
        ),
        ListTile(
          title: const Text('Temas disponibles'),
          subtitle: const Text('Elige los temas que el niño puede usar'),
          trailing: ElevatedButton(
            onPressed: _onConfigureThemes,
            child: const Text('Configurar'),
          ),
        ),
      ],
    );
  }

  Widget _buildNightModeSection() => ListView(
      children: <Widget>[
        _sectionTitle('Modo noche o descanso'),
        SwitchListTile(
          title: const Text('Activar modo noche'),
          value: _nightModeActive,
          onChanged: _setNightMode,
        ),
        ListTile(
          title: const Text('Programar horario automático'),
          subtitle: Text(_nightStart != null && _nightEnd != null ? 'De ${_nightStart!.format(context)} a ${_nightEnd!.format(context)}' : 'No programado'),
          trailing: ElevatedButton(
            onPressed: _pickNightSchedule,
            child: const Text('Configurar horario'),
          ),
        ),
        const ListTile(
          title: Text('Atenuar colores y desactivar sonidos'),
          subtitle: Text('Se aplicará automáticamente en modo noche'),
        ),
      ],
    );

  Widget _sectionTitle(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
      ),
    );

  Widget _statCard(String label, String value, IconData icon, Color color) => Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: GoogleFonts.nunito()),
      ),
    );

  // Métodos de acción (placeholders)
  void _onConfigureThemes() {}
  void _onChangePin() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => const _ChangePinDialog(),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN cambiado correctamente')),
      );
    }
  }
  void _onLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar la sesión actual?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final LocalStorageService prefs = LocalStorageService();
      await prefs.setActiveProfile(''); // Elimina el perfil activo
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (Route route) => false,
        );
      }
    }
  }
}

class _GoalDialog extends StatefulWidget {
  final Goal? goal;
  const _GoalDialog({this.goal, Key? key}) : super(key: key);

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late int _targetValue;
  late String _unit;
  late int _coinsReward;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    _title = widget.goal?.title ?? '';
    _description = widget.goal?.description ?? '';
    _targetValue = widget.goal?.targetValue ?? 1;
    _unit = widget.goal?.unit ?? 'veces';
    _coinsReward = widget.goal?.coinsReward ?? 1;
    _difficulty = widget.goal?.difficulty ?? 'medium';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(widget.goal == null ? 'Nueva meta' : 'Editar meta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (String? v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                onChanged: (String v) => _title = v,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (String v) => _description = v,
              ),
              TextFormField(
                initialValue: _targetValue.toString(),
                decoration: const InputDecoration(labelText: 'Valor objetivo'),
                keyboardType: TextInputType.number,
                validator: (String? v) => v == null || int.tryParse(v) == null ? 'Obligatorio' : null,
                onChanged: (String v) => _targetValue = int.tryParse(v) ?? 1,
              ),
              TextFormField(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unidad (veces, minutos, etc.)'),
                onChanged: (String v) => _unit = v,
              ),
              TextFormField(
                initialValue: _coinsReward.toString(),
                decoration: const InputDecoration(labelText: 'Recompensa (monedas)'),
                keyboardType: TextInputType.number,
                validator: (String? v) => v == null || int.tryParse(v) == null ? 'Obligatorio' : null,
                onChanged: (String v) => _coinsReward = int.tryParse(v) ?? 1,
              ),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Dificultad'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'easy', child: Text('Fácil')),
                  DropdownMenuItem(value: 'medium', child: Text('Media')),
                  DropdownMenuItem(value: 'hard', child: Text('Difícil')),
                ],
                onChanged: (String? v) => setState(() => _difficulty = v ?? 'medium'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final Goal goal = Goal(
                id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: _title,
                description: _description,
                targetValue: _targetValue,
                currentValue: widget.goal?.currentValue ?? 0,
                unit: _unit,
                coinsReward: _coinsReward,
                isCompleted: widget.goal?.isCompleted ?? false,
                createdAt: widget.goal?.createdAt ?? DateTime.now(),
                category: 'personalizada',
                isRecurring: false,
                recurrenceType: null,
                reward: null,
                difficulty: _difficulty,
              );
              Navigator.pop(context, goal);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
}

class _RewardDialog extends StatefulWidget {
  final Achievement? reward;
  const _RewardDialog({this.reward, Key? key}) : super(key: key);

  @override
  State<_RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<_RewardDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late int _coins;
  late String _iconName;

  @override
  void initState() {
    super.initState();
    _title = widget.reward?.title ?? '';
    _description = widget.reward?.description ?? '';
    _coins = 10;
    _iconName = widget.reward?.iconName ?? 'card_giftcard';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(widget.reward == null ? 'Nueva recompensa' : 'Editar recompensa'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (String? v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                onChanged: (String v) => _title = v,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (String v) => _description = v,
              ),
              TextFormField(
                initialValue: _coins.toString(),
                decoration: const InputDecoration(labelText: 'Monedas necesarias'),
                keyboardType: TextInputType.number,
                validator: (String? v) => v == null || int.tryParse(v) == null ? 'Obligatorio' : null,
                onChanged: (String v) => _coins = int.tryParse(v) ?? 10,
              ),
              DropdownButtonFormField<String>(
                value: _iconName,
                decoration: const InputDecoration(labelText: 'Icono'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'card_giftcard', child: Text('Regalo')),
                  DropdownMenuItem(value: 'park', child: Text('Parque')),
                  DropdownMenuItem(value: 'movie', child: Text('Película')),
                  DropdownMenuItem(value: 'toys', child: Text('Juguete')),
                  DropdownMenuItem(value: 'star', child: Text('Estrella')),
                ],
                onChanged: (String? v) => setState(() => _iconName = v ?? 'card_giftcard'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final Achievement reward = Achievement(
                id: widget.reward?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: _title,
                description: _description,
                iconName: _iconName,
                isUnlocked: false,
                unlockedAt: null,
                category: 'personalizada',
              );
              Navigator.pop(context, reward);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog({Key? key}) : super(key: key);
  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ParentPinService pinService = ParentPinService();
    final bool valid = await pinService.validatePin(_currentPinController.text);
    if (!valid) {
      setState(() {
        _loading = false;
        _error = 'El PIN actual es incorrecto';
      });
      return;
    }
    await pinService.changePin(_newPinController.text);
    setState(() { _loading = false; });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Cambiar PIN de padres'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _currentPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN actual'),
              validator: (String? v) => v == null || v.length != 4 ? 'Obligatorio' : null,
            ),
            TextFormField(
              controller: _newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nuevo PIN'),
              validator: (String? v) => v == null || v.length != 4 ? 'Obligatorio' : null,
            ),
            TextFormField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar nuevo PIN'),
              validator: (String? v) => v != _newPinController.text ? 'No coincide' : null,
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _changePin,
          child: _loading ? const CircularProgressIndicator() : const Text('Guardar'),
        ),
      ],
    );
} 