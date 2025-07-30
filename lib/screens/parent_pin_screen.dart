import 'package:flutter/material.dart';
import '../services/parent_pin_service.dart';
import 'parent_mode_screen.dart';
import 'create_parent_pin_screen.dart';

class ParentPinScreen extends StatefulWidget {
  const ParentPinScreen({Key? key}) : super(key: key);

  @override
  State<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends State<ParentPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;
  int _attempts = 0;
  String? _revealedPin;

  Future<void> _checkPin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ParentPinService pinService = ParentPinService();
    final String pin = _pinController.text;
    final bool valid = await pinService.validatePin(pin);
    final int attempts = await pinService.getAttempts();
    setState(() { _loading = false; _attempts = attempts; });
    if (valid) {
      await pinService.resetAttempts();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ParentModeScreen()),
      );
    } else {
      if (_attempts >= 3) {
        final String? savedPin = await pinService.getPin();
        setState(() { _revealedPin = savedPin; });
      } else {
        setState(() { _error = 'PIN incorrecto. Intento $_attempts de 3.'; });
      }
    }
  }

  Future<void> _checkIfPinExists() async {
    final ParentPinService pinService = ParentPinService();
    final String? pin = await pinService.getPin();
    if (pin == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CreateParentPinScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfPinExists();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Modo Padres')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _revealedPin != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Tu pin es: $_revealedPin', style: const TextStyle(fontSize: 22, color: Colors.red)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() { _revealedPin = null; _attempts = 0; }),
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Introduce tu PIN de padres', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'PIN (4 dígitos)'),
                        validator: (String? v) {
                          if (v == null || v.length != 4) return 'Debe tener 4 dígitos';
                          if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Solo números';
                          return null;
                        },
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _checkPin,
                        child: _loading ? const CircularProgressIndicator() : const Text('Entrar'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
} 