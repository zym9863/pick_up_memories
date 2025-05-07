import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/memory_item.dart';
import '../services/memory_database.dart';
import 'memory_form_screen.dart';

class MemoryDetailScreen extends StatelessWidget {
  final MemoryItem memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memory.title, style: Theme.of(context).appBarTheme.titleTextStyle),
        // 使用主题的 AppBar 背景色，如果 memory.mood.color 需要保留，可以考虑其他方式融合
        // backgroundColor: memory.mood.color, 
        // foregroundColor: Colors.white, // 已在主题中定义
        // 如果希望 mood 颜色影响 AppBar，可以这样做:
        // backgroundColor: Color.alphaBlend(memory.mood.color.withOpacity(0.2), Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryFormScreen(memory: memory),
                ),
              ).then((_) => Navigator.pop(context));
            },
            tooltip: '编辑',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmDialog(context);
            },
            tooltip: '删除',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期和地点
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yyyy年MM月dd日').format(memory.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (memory.location != null) ...[  
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        memory.location!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 心情
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(memory.mood.icon, color: memory.mood.color, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '心情: ${memory.mood.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // 内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                memory.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5), // 增加行高以提高可读性
              ),
            ),
            
            // 图片
            if (memory.imagePaths.isNotEmpty) ...[  
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 调整下方间距
                child: Text(
                  '照片',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: memory.imagePaths.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _showFullScreenImage(context, memory.imagePaths[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(memory.imagePaths[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 显示全屏图片
  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除回忆', style: Theme.of(context).textTheme.titleLarge),
        content: Text('确定要删除这条回忆吗？此操作不可恢复。', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () async {
              await MemoryDatabase().deleteMemory(memory.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // 关闭对话框
                Navigator.of(context).pop(); // 返回上一页
              }
            },
            child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}