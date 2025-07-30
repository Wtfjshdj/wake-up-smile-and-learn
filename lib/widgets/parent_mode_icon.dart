import 'package:flutter/material.dart';

class ParentModeIcon extends StatelessWidget {
  final VoidCallback onTap;
  const ParentModeIcon({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
      icon: const Icon(Icons.groups), // Ícono de dos personas
      tooltip: 'Modo Padres',
      onPressed: onTap,
    );
} 