import 'package:flutter/material.dart';
import '../widgets/gender_selector.dart';
import '../widgets/interests_checkbox_list.dart';
import '../services/local_storage_service.dart';
import '../models/user_preferences.dart'; // Asegúrate de tener este import

/// Widget that handles initial user configuration
class InitialConfigScreen extends StatefulWidget {
  /// Creates a new instance of [InitialConfigScreen]
  const InitialConfigScreen({Key? key}) : super(key: key);

  @override
  State<InitialConfigScreen> createState() => _InitialConfigScreenState();
}

class _InitialConfigScreenState extends State<InitialConfigScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Campos del formulario
  String? nombre;
  String? grupoEdad;
  String? genero;
  String? nivelIngles;
  List<String> intereses = <String>[];
  List<String> cancionesFavoritas = <String>[];
  String cancionInput = '';

  // Opciones
  final List<String> gruposEdad = <String>['5-7 años', '8-10 años'];
  final List<String> nivelesIngles = <String>['Principiante', 'Intermedio', 'Avanzado'];
  final List<String> interesesDisponibles = <String>['Animales', 'Deportes', 'Música', 'Dibujar', 'Historias'];

  bool guardando = false;
  String? mensajeError;
  String? mensajeExito;

  // Animación de pasos
  int currentStep = 0;

  void nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
        mensajeError = null;
        mensajeExito = null;
      });
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        mensajeError = null;
        mensajeExito = null;
      });
    }
  }

  Future<void> guardarPreferencias() async {
    setState(() {
      guardando = true;
      mensajeError = null;
      mensajeExito = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        guardando = false;
        mensajeError = 'Por favor, completa los campos obligatorios.';
      });
      return;
    }

    _formKey.currentState!.save();

    final UserPreferences prefs = UserPreferences(
      name: nombre ?? '',
      ageGroup: grupoEdad ?? '',
      gender: genero ?? '',
      englishLevel: nivelIngles ?? '',
      interests: intereses,
      favoriteSongs: cancionesFavoritas,
    );

    try {
      await LocalStorageService().saveUserPreferences(prefs);
      setState(() {
        guardando = false;
        mensajeExito = '¡Preferencias guardadas con éxito!';
      });
    } catch (e) {
      setState(() {
        guardando = false;
        mensajeError = 'Error al guardar preferencias.';
      });
    }
  }

  Widget buildNombreEdadStep() => Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('¡Bienvenido!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(
              labelText: '¿Cómo te llamas?',
              border: OutlineInputBorder(),
            ),
            onSaved: (String? val) => nombre = val,
            validator: (String? val) => val == null || val.trim().isEmpty ? 'El nombre es obligatorio' : null,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '¿Cuántos años tienes?',
              border: OutlineInputBorder(),
            ),
            items: gruposEdad
                .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (String? val) => setState(() => grupoEdad = val),
            validator: (String? val) => val == null ? 'Selecciona tu grupo de edad' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.orange,
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) nextStep();
            },
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );

  Widget buildGeneroInglesStep() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Cuéntanos más de ti', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 24),
        const Text('¿Eres niño, niña o prefieres no decirlo?', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        GenderSelector(
          selectedGender: genero,
          onChanged: (String val) => setState(() => genero = val),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: '¿Cuál es tu nivel de inglés?',
            border: OutlineInputBorder(),
          ),
          items: nivelesIngles
              .map((String e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (String? val) => setState(() => nivelIngles = val),
          validator: (String? val) => val == null ? 'Selecciona tu nivel de inglés' : null,
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
                backgroundColor: Colors.grey,
              ),
              onPressed: prevStep,
              child: const Text('Atrás'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
                backgroundColor: Colors.orange,
              ),
              onPressed: (nivelIngles != null)
                  ? nextStep
                  : null,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ],
    );

  Widget buildInteresesCancionesStep() => SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('¡Personaliza tu experiencia!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 24),
          const Text('¿Qué te interesa?', style: TextStyle(fontSize: 18)),
          InterestsCheckboxList(
            allInterests: interesesDisponibles,
            selectedInterests: intereses,
            onChanged: (List<String> list) => setState(() => intereses = list),
          ),
          const SizedBox(height: 24),
          const Text('¿Tienes canciones favoritas para despertar?', style: TextStyle(fontSize: 18)),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la canción',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String val) => cancionInput = val,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  if (cancionInput.trim().isNotEmpty) {
                    setState(() {
                      cancionesFavoritas.add(cancionInput.trim());
                      cancionInput = '';
                    });
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: cancionesFavoritas
                .map((String cancion) => Chip(
                      label: Text(cancion),
                      onDeleted: () => setState(() => cancionesFavoritas.remove(cancion)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          if (mensajeError != null)
            Text(mensajeError!, style: const TextStyle(color: Colors.red)),
          if (mensajeExito != null)
            Text(mensajeExito!, style: const TextStyle(color: Colors.green)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.orange,
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: guardando ? null : guardarPreferencias,
            child: guardando
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('¡Guardar y empezar!'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.grey,
            ),
            onPressed: prevStep,
            child: const Text('Atrás'),
          ),
        ],
      ),
    );

  Widget buildStep() {
    switch (currentStep) {
      case 0:
        return buildNombreEdadStep();
      case 1:
        return buildGeneroInglesStep();
      case 2:
        return buildInteresesCancionesStep();
      default:
        return const Center(child: Text('¡Listo!'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.orange[50],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          key: ValueKey(currentStep),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: buildStep(),
            ),
          ),
        ),
      ),
    );
}