import 'package:flutter/material.dart';
import 'package:project/screens/add_exist_tagged_device_screen.dart';
import 'package:provider/provider.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/login_screen.dart';
import 'package:project/screens/add_devices_screen.dart';
import 'package:project/screens/device_screen.dart';
import 'package:project/screens/qr_code_scanner_screen.dart';
import 'package:project/screens/search_screen.dart';


// --- 路由名称常量 ---
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String device = '/device';
  static const String qrScanner = '/qr_scanner';
  static const String search = '/search';
  static const String addDevice = '/add_device';
  static const String addExistTaggedDevice = '/add_exist_tagged_device';

  // --- 路由映射表 ---
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      device: (context) => const DeviceScreen(),
      qrScanner: (context) => const QrScannerScreen(),
      search: (context) => const SearchScreen(),
      addDevice: (context) => const AddDeviceScreen(),
      addExistTaggedDevice: (context) => const AddExistTaggedDeviceScreen(),
    };
  }
}

// --- main 函数 ---
void main() {
  // 4. 确保 Flutter 绑定已初始化 (异步操作前需要)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // 5. 使用 ChangeNotifierProvider 提供 AuthService
    ChangeNotifierProvider(
      create: (context) => AuthService(), // 创建 AuthService 实例
      child: const MyApp(), // MyApp 作为子 Widget
    ),
  );
}

// --- MyApp Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo App',
      theme: ThemeData( // 保持你现有的主题设置
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: Colors.grey[600],
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[200],
          thickness: 1,
        ),
        // ... 其他主题设置 ...
      ),

      // --- 6. 修改启动逻辑：使用 Consumer 根据 Auth 状态决定首页 ---
      // initialRoute: AppRoutes.home, // 移除 initialRoute
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          print('[MyApp] 监听 Auth 状态: ${authService.isLoggedIn}'); // 调试打印
          // 在这里可以添加一个加载状态判断（如果 AuthService 有 isLoading 标志）
          // if (authService.isLoading) {
          //   return const SplashScreen(); // 或者一个简单的加载指示器
          // }

          if (authService.isLoggedIn) {
            // 如果已登录，显示主屏幕
            return const HomeScreen();
          } else {
            // 如果未登录，显示登录屏幕
            return const LoginScreen();
          }
        },
      ),
      // ---

      // 7. 提供路由表，用于登录后的页面导航
      routes: AppRoutes.routes,

      // onUnknownRoute 保持不变
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('错误')),
            body: Center(
              child: Text('路由 ${settings.name} 未定义'), // 提示信息本地化
            ),
          ),
        );
      },

      debugShowCheckedModeBanner: false,
    );
  }
}