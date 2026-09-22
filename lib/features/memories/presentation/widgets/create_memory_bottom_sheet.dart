import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/memory_capture_result.dart';
import '../../data/models/memory_model.dart';

enum MemoryCategory {
  food('Food', '🍜'),
  accommodation('Accommodation', '🏨'),
  entertainment('Entertainment', '🎟️'),
  nature('Nature', '🌿'),
  transport('Transport', '🚆'),
  cafe('Cafe', '☕'),
  other('Other', '📌');

  final String label;
  final String icon;
  const MemoryCategory(this.label, this.icon);
}

class CreateMemoryBottomSheet extends StatefulWidget {
  final MemoryCaptureResult capture;
  final String? currentCountryIso;
  final Function(MemoryModel) onSave;

  const CreateMemoryBottomSheet({
    super.key,
    required this.capture,
    required this.onSave,
    this.currentCountryIso,
  });

  @override
  State<CreateMemoryBottomSheet> createState() =>
      _CreateMemoryBottomSheetState();
}

class _CreateMemoryBottomSheetState
    extends State<CreateMemoryBottomSheet> {
  MemoryCategory _selectedCategory = MemoryCategory.food;
  final TextEditingController _descController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.capture.imagePath),
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'What is it?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: MemoryCategory.values.map((cat) {
              return ChoiceChip(
                label: Text('${cat.icon} ${cat.label}'),
                selected: _selectedCategory == cat,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'Description (буквально пару слов)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _save,
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final memory = MemoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: widget.capture.imagePath,
      category: _selectedCategory.name,
      description: _descController.text.trim(),
      createdAt: widget.capture.createdAt,
      latitude: widget.capture.position?.latitude,
      longitude: widget.capture.position?.longitude,
      countryIso: widget.currentCountryIso,
    );

    widget.onSave(memory);
    Navigator.of(context).pop();
  }
}
