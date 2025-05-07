[English](README_EN.md) | [中文](README.md)

# pick_up_memories

一个记录和回顾珍贵回忆的 Flutter 应用。

## 项目简介

pick_up_memories 旨在帮助用户以图文方式记录生活中的重要时刻，并通过时间线、详情页等方式回顾美好回忆。项目采用模块化设计，便于维护和扩展。

## 主要功能
- 添加、编辑和删除回忆（支持图片和文字）
- 按时间线浏览所有回忆
- 查看回忆详情
- 数据本地持久化存储

## 目录结构
```
lib/
├── main.dart                // 应用入口
├── models/                  // 数据模型
│   └── memory_item.dart     // 回忆数据结构定义
├── screens/                 // 各功能页面
│   ├── home_screen.dart         // 首页，展示回忆列表
│   ├── memory_detail_screen.dart // 回忆详情页
│   ├── memory_form_screen.dart   // 添加/编辑回忆页
│   └── timeline_screen.dart      // 时间线视图
└── services/                // 业务逻辑与数据服务
    └── memory_database.dart // 本地数据库操作
```

### 目录说明
- **models/**：定义应用的数据结构，便于数据管理和类型检查。
- **screens/**：包含所有页面的 UI 及交互逻辑，遵循组件化思想，便于维护和复用。
- **services/**：封装与本地数据库的交互逻辑，实现数据的持久化存储。

## 关键依赖
- sqflite、sqflite_common_ffi：本地数据库存储
- path_provider、path：文件路径管理
- provider：状态管理
- image_picker：图片选择
- flutter_staggered_grid_view：瀑布流布局
- table_calendar：日历组件

## 启动方式
1. 安装依赖：
   ```
   flutter pub get
   ```
2. 运行项目：
   ```
   flutter run
   ```

## 其他
- 代码遵循模块化、可维护性高的设计原则。
- 欢迎提出建议和贡献代码。
