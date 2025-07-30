import 'package:flutter/material.dart';

/// Widget for selecting gender
class GenderSelector extends StatefulWidget {
  /// Creates a new instance of [GenderSelector]
  const GenderSelector({
    this.selectedGender,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// Currently selected gender
  final String? selectedGender;

  /// Callback when gender selection changes
  final void Function(String) onChanged;

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  late String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.selectedGender;
  }

  @override
  Widget build(BuildContext context) => Row(
      children: <Widget>[
        ChoiceChip(
          label: const Text('Niño'),
          selected: _selectedGender == 'Niño',
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                _selectedGender = 'Niño';
              });
              widget.onChanged('Niño');
            }
          },
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Niña'),
          selected: _selectedGender == 'Niña',
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                _selectedGender = 'Niña';
              });
              widget.onChanged('Niña');
            }
          },
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Prefiero no decirlo'),
          selected: _selectedGender == 'Prefiero no decirlo',
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                _selectedGender = 'Prefiero no decirlo';
              });
              widget.onChanged('Prefiero no decirlo');
            }
          },
        ),
      ],
    );
}

