import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/memory_item.dart';
import '../services/memory_database.dart';
import 'memory_detail_screen.dart';
import 'memory_form_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<MemoryItem> _memories = [];
  List<MemoryItem> _thisDayMemories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMemories();
    _checkThisDayMemories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加载所有回忆
  Future<void> _loadMemories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final memories = await MemoryDatabase().getMemories();
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载回忆失败: $e')),
        );
      }
    }
  }

  // 检查"那年今日"的回忆
  Future<void> _checkThisDayMemories() async {
    try {
      final thisDayMemories = await MemoryDatabase().getMemoriesOnThisDay();
      setState(() {
        _thisDayMemories = thisDayMemories;
      });
      
      // 如果有"那年今日"的回忆，显示提醒
      if (_thisDayMemories.isNotEmpty && mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('那年今日'),
              content: Text('你有${_thisDayMemories.length}条往年今日的回忆'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('稍后查看'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showThisDayMemories();
                  },
                  child: const Text('立即查看'),
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取往年今日回忆失败: $e')),
        );
      }
    }
  }

  // 显示"那年今日"的回忆
  void _showThisDayMemories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '那年今日',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _thisDayMemories.length,
                itemBuilder: (context, index) {
                  final memory = _thisDayMemories[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(memory.title, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(
                        '${DateFormat('yyyy年MM月dd日').format(memory.date)}\n${memory.content.length > 50 ? memory.content.substring(0, 50) + '...' : memory.content}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: memory.mood.color,
                        child: Icon(memory.mood.icon, color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemoryDetailScreen(memory: memory),
                          ),
                        ).then((_) => _loadMemories());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拾忆'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _thisDayMemories.isNotEmpty ? _showThisDayMemories : null,
            tooltip: '那年今日',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: '日历'),
            Tab(icon: Icon(Icons.timeline), text: '时光轴'),
          ],
          // 使用主题颜色以保持一致性
          labelColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
          unselectedLabelColor: (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white).withOpacity(0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 日历视图
          _buildCalendarView(),
          // 时光轴视图
          TimelineScreen(memories: _memories, onRefresh: _loadMemories),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemoryFormScreen(),
            ),
          ).then((_) => _loadMemories());
        },
        child: const Icon(Icons.add),
        tooltip: '添加回忆',
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _loadSelectedDayMemories(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
        ),
        const Divider(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMemoryList(),
        ),
      ],
    );
  }

  // 加载选定日期的回忆
  Future<void> _loadSelectedDayMemories(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final memories = await MemoryDatabase().getMemoriesByDate(date);
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载回忆失败: $e')),
        );
      }
    }
  }

  Widget _buildMemoryList() {
    if (_memories.isEmpty) {
      return const Center(
        child: Text(
          '没有回忆记录',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final memory = _memories[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              memory.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  memory.content.length > 100
                      ? '${memory.content.substring(0, 100)}...'
                      : memory.content,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy年MM月dd日').format(memory.date),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (memory.location != null) ...[  
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        memory.location!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: memory.mood.color,
              child: Icon(memory.mood.icon, color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryDetailScreen(memory: memory),
                ),
              ).then((_) => _loadMemories());
            },
          ),
        );
      },
    );
  }
}