import 'package:flutter/material.dart';

class EmotionTagSelector extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final ValueChanged<String> onChanged;

  const EmotionTagSelector({
    required this.tags,
    required this.selectedTag,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        final isSelected = tag == selectedTag;
        return ChoiceChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => onChanged(tag),
        );
      }).toList(),
    );
  }
}