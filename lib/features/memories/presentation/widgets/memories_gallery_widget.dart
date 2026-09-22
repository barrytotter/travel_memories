import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/features/memories/data/models/memory_model.dart';
import 'package:travel_memories/features/memories/data/services/memory_capture_service.dart';
import 'package:travel_memories/features/memories/presentation/widgets/create_memory_bottom_sheet.dart';

class MemoriesGalleryWidget extends StatelessWidget {
  final String? countryIso;

  const MemoriesGalleryWidget({super.key, this.countryIso});

  @override
  Widget build(BuildContext context) {
    final memoryBox = getIt<Box<MemoryModel>>();

    return ValueListenableBuilder(
      valueListenable: memoryBox.listenable(),
      builder: (context, Box<MemoryModel> box, _) {
        // Фильтруем воспоминания по ISO страны, если параметр передан
        final memories =
            box.values.where((memory) {
              if (countryIso == null) return true;
              return memory.countryIso?.toLowerCase() ==
                  countryIso?.toLowerCase();
            }).toList()..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );

        if (memories.isEmpty) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filledTonal(
                  onPressed: () => _addMemory(context),
                  icon: const Icon(Icons.add_a_photo),
                  tooltip: 'Добавить фото',
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Пока нет сохранённых воспоминаний.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton.filledTonal(
                onPressed: () => _addMemory(context),
                icon: const Icon(Icons.add_a_photo),
                tooltip: 'Добавить фото',
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                final file = File(memory.imagePath);

                return GestureDetector(
                  onTap: () =>
                      _showMemoryDetails(context, memory),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        file.existsSync()
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                ),
                              ),
                        if (memory.category.isNotEmpty)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius:
                                    BorderRadius.circular(
                                      4,
                                    ),
                              ),
                              child: Text(
                                memory.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMemory(BuildContext context) async {
    final capture = await getIt<MemoryCaptureService>()
        .capture();

    if (capture == null || !context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return CreateMemoryBottomSheet(
          capture: capture,
          currentCountryIso: countryIso,
          onSave: (memory) async {
            final memoryBox = getIt<Box<MemoryModel>>();

            await memoryBox.add(memory);

            debugPrint('Memory saved: ${memory.id}');
          },
        );
      },
    );
  }

  void _showMemoryDetails(
    BuildContext context,
    MemoryModel memory,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.file(
                  File(memory.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (memory.description.isNotEmpty) ...[
                    Text(
                      memory.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Дата: ${memory.createdAt.toString().split('.')[0]}',
                  ),
                  if (memory.latitude != null &&
                      memory.longitude != null)
                    Text(
                      'GPS: ${memory.latitude!.toStringAsFixed(4)}, ${memory.longitude!.toStringAsFixed(4)}',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
