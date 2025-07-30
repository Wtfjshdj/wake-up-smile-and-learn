import 'package:flutter/material.dart';

/// Widget for selecting age from a dropdown
class AgeDropdown extends StatelessWidget {
  /// Creates a new instance of [AgeDropdown]
  const AgeDropdown({
    required this.onChanged,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  /// Callback when age selection changes
  final void Function(int?) onChanged;

  /// Initially selected age
  final int? initialValue;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
      value: initialValue,
      items: List<DropdownMenuItem<int>>.generate(
        100,
        (int index) => DropdownMenuItem<int>(
          value: index + 1,
          child: Text((index + 1).toString()),
        ),
      ),
      onChanged: onChanged,
    );
}
