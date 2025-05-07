import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/memory_item.dart';
import '../services/memory_database.dart';

class MemoryFormScreen extends StatefulWidget {
  final MemoryItem? memory; // 如果是编辑模式，则传入现有的回忆对象

  const MemoryFormScreen({super.key, this.memory});

  @override
  State<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends State<MemoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  Mood _selectedMood = Mood.happy;
  List<String> _imagePaths = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，填充表单
    if (widget.memory != null) {
      _titleController.text = widget.memory!.title;
      _contentController.text = widget.memory!.content;
      _locationController.text = widget.memory!.location ?? '';
      _selectedDate = widget.memory!.date;
      _selectedMood = widget.memory!.mood;
      _imagePaths = List.from(widget.memory!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('zh'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  // 拍照
  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        setState(() {
          _imagePaths.add(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  // 保存回忆
  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final memory = MemoryItem(
          id: widget.memory?.id ?? const Uuid().v4(),
          title: _titleController.text,
          content: _contentController.text,
          date: _selectedDate,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          mood: _selectedMood,
          imagePaths: _imagePaths,
        );

        if (widget.memory == null) {
          // 创建新回忆
          await MemoryDatabase().insertMemory(memory);
        } else {
          // 更新现有回忆
          await MemoryDatabase().updateMemory(memory);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存回忆失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memory == null ? '创建回忆' : '编辑回忆', style: Theme.of(context).appBarTheme.titleTextStyle),
        // backgroundColor and foregroundColor are already handled by appBarTheme in main.dart
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveMemory,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '标题',
                        border: const OutlineInputBorder(),
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 日期选择
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '日期',
                          border: const OutlineInputBorder(),
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy年MM月dd日').format(_selectedDate), style: Theme.of(context).textTheme.bodyLarge),
                            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 地点
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: '地点 (可选)',
                        border: const OutlineInputBorder(),
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 心情选择
                    Text('心情', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12, // 调整间距
                      runSpacing: 8, // 调整行间距
                      children: Mood.values.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return ChoiceChip(
                          avatar: Icon(mood.icon, color: isSelected ? Colors.white : mood.color, size: 20),
                          label: Text(mood.name, style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedMood = mood;
                              });
                            }
                          },
                          selectedColor: mood.color,
                          backgroundColor: mood.color.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // 内容
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: '内容',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      maxLines: 8,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入内容';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 图片
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('照片', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                              onPressed: _pickImage,
                              tooltip: '从相册选择',
                            ),
                            IconButton(
                              icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                              onPressed: _takePhoto,
                              tooltip: '拍照',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_imagePaths.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return ClipRRect( // 使用 ClipRRect 来确保圆角效果
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    File(_imagePaths[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Material( // 使用 Material 包裹 InkWell 以确保水波纹效果在圆角内
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      borderRadius: BorderRadius.circular(12), // 匹配图标背景的圆角
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}