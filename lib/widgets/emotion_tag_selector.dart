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
      spacing: 12,
      runSpacing: 12,
      children: tags.map((tag) {
        final isSelected = tag == selectedTag;
        return GestureDetector(
          onTap: () => onChanged(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}