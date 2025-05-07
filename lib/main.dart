import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据平台选择合适的数据库初始化方式
  if (Platform.isWindows || Platform.isLinux) {
    // 在桌面平台上使用FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else if (Platform.isAndroid) {
    // 在Android平台上，确保使用sqlite3_flutter_libs提供的二进制文件
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // 在iOS和macOS上，默认使用原生sqflite，不需要特殊处理
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拾忆',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7), // 更深的紫色作为种子颜色
          primary: const Color(0xFF673AB7), // 主色调
          secondary: const Color(0xFFFFC107), // 次要/强调色
          // 可以根据需要定义更多颜色，如 surface, background, error 等
        ),
        useMaterial3: true,
        fontFamily: 'NotoSansSC', // 尝试使用一个更通用的中文字体，如果项目中包含的话
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
          bodySmall: TextStyle(fontSize: 12.0),
          labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF673AB7), // AppBar 背景色
          foregroundColor: Colors.white, // AppBar 前景色 (标题和图标)
          elevation: 4.0, // AppBar 阴影
          titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, fontFamily: 'NotoSansSC', color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107), // FAB 背景色
          foregroundColor: Colors.black, // FAB 图标颜色
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7), // 按钮背景色
            foregroundColor: Colors.white, // 按钮文字颜色
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'NotoSansSC'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF673AB7), // 文本按钮文字颜色
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'NotoSansSC'),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      home: const HomeScreen(),
      // 添加中文本地化支持
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
    );
  }
}
