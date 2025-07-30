import 'package:flutter/material.dart';
import '../services/parent_pin_service.dart';

class CreateParentPinScreen extends StatefulWidget {
  final bool fromOnboarding;
  const CreateParentPinScreen({Key? key, this.fromOnboarding = false}) : super(key: key);

  @override
  State<CreateParentPinScreen> createState() => _CreateParentPinScreenState();
}

class _CreateParentPinScreenState extends State<CreateParentPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final ParentPinService pinService = ParentPinService();
    await pinService.setPin(_pinController.text);
    setState(() { _loading = false; });
    if (widget.fromOnboarding) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: widget.fromOnboarding ? null : AppBar(title: const Text('Crear PIN')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Crea tu clave de acceso al modo padres.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
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
                TextFormField(
                  controller: _confirmController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmar PIN'),
                  validator: (String? v) {
                    if (v != _pinController.text) return 'No coincide';
                    return null;
                  },
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _savePin,
                  child: _loading ? const CircularProgressIndicator() : const Text('Guardar PIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
} 