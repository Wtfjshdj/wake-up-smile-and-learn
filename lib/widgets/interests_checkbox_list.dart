import 'package:flutter/material.dart';

/// Widget for selecting multiple interests
class InterestsCheckboxList extends StatefulWidget {
  /// Creates a new instance of [InterestsCheckboxList]
  const InterestsCheckboxList({
    required this.allInterests,
    required this.selectedInterests,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// List of all available interests
  final List<String> allInterests;

  /// Currently selected interests
  final List<String> selectedInterests;

  /// Callback when selections change
  final void Function(List<String>) onChanged;

  @override
  State<InterestsCheckboxList> createState() => _InterestsCheckboxListState();
}

class _InterestsCheckboxListState extends State<InterestsCheckboxList> {
  late List<String> _selectedInterests;

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(widget.selectedInterests);
  }

  @override
  Widget build(BuildContext context) => Column(
      children: widget.allInterests.map((String interest) => CheckboxListTile(
          title: Text(interest),
          value: _selectedInterests.contains(interest),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }
            });
            widget.onChanged(_selectedInterests);
          },
        )).toList(),
    );
}
