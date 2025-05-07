import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/memory_item.dart';
import 'memory_detail_screen.dart';

class TimelineScreen extends StatelessWidget {
  final List<MemoryItem> memories;
  final Function onRefresh;

  const TimelineScreen({
    super.key,
    required this.memories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // 按日期排序（从新到旧）
    final sortedMemories = List<MemoryItem>.from(memories)
      ..sort((a, b) => b.date.compareTo(a.date));

    // 按年份和月份分组
    final Map<String, List<MemoryItem>> groupedMemories = {};
    for (var memory in sortedMemories) {
      final yearMonth = DateFormat('yyyy年MM月').format(memory.date);
      if (!groupedMemories.containsKey(yearMonth)) {
        groupedMemories[yearMonth] = [];
      }
      groupedMemories[yearMonth]!.add(memory);
    }

    // 获取所有年月键并排序
    final yearMonthKeys = groupedMemories.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 从新到旧排序

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '没有回忆记录',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
      },
      child: ListView.builder(
        itemCount: yearMonthKeys.length,
        itemBuilder: (context, index) {
          final yearMonth = yearMonthKeys[index];
          final monthMemories = groupedMemories[yearMonth]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Text(
                    yearMonth,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthMemories.length,
                itemBuilder: (context, idx) {
                  final memory = monthMemories[idx];
                  return _buildTimelineItem(context, memory, idx == monthMemories.length - 1);
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, MemoryItem memory, bool isLast) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryDetailScreen(memory: memory),
          ),
        ).then((_) => onRefresh());
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              DateFormat('dd日').format(memory.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: memory.mood.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(memory.mood.icon, color: Colors.white, size: 16),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80, // Consider making this dynamic based on content
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  memory.content.length > 100
                      ? '${memory.content.substring(0, 100)}...'
                      : memory.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 8),
                if (memory.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          memory.location!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (memory.imagePaths.isNotEmpty)
                  Container(
                    height: 80,
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: memory.imagePaths.length,
                        itemBuilder: (context, index) {
                          if (index < 2 || memory.imagePaths.length == 3) { // Show first 2 images, or all 3 if total is 3
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  File(memory.imagePaths[index]),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else if (index == 2 && memory.imagePaths.length > 3) { // Show '+more' indicator
                            return Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(memory.imagePaths[index])),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '+${memory.imagePaths.length - 2}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink(); // Don't show more than 3 items (2 images + 1 indicator)
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}