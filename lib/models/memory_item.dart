import 'package:flutter/material.dart';

/// 心情枚举类型
enum Mood {
  happy(icon: Icons.sentiment_very_satisfied, color: Colors.amber),
  good(icon: Icons.sentiment_satisfied, color: Colors.lightGreen),
  neutral(icon: Icons.sentiment_neutral, color: Colors.blueGrey),
  bad(icon: Icons.sentiment_dissatisfied, color: Colors.orange),
  awful(icon: Icons.sentiment_very_dissatisfied, color: Colors.red);

  final IconData icon;
  final Color color;

  const Mood({required this.icon, required this.color});
}

/// 回忆条目模型
class MemoryItem {
  final String id; // 唯一标识符
  final String title; // 标题
  final String content; // 内容
  final DateTime date; // 日期
  final String? location; // 地点，可选
  final Mood mood; // 心情
  final List<String> imagePaths; // 图片路径列表

  MemoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.location,
    required this.mood,
    required this.imagePaths,
  });

  // 从JSON创建对象的工厂构造函数
  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      mood: Mood.values.firstWhere((e) => e.name == json['mood']),
      imagePaths: List<String>.from(json['imagePaths']),
    );
  }

  // 将对象转换为JSON的方法
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'location': location,
      'mood': mood.name,
      'imagePaths': imagePaths,
    };
  }

  // 创建一个带有新值的MemoryItem副本
  MemoryItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? location,
    Mood? mood,
    List<String>? imagePaths,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}