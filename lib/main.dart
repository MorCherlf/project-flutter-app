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
import 'package:project/screens/application_screen.dart';
import 'package:project/services/data_service.dart';
import 'package:project/screens/add_new_device_screen.dart';
import 'package:project/screens/add_new_device_form.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/firebase_options.dart';

// --- 路由名称常量 ---
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String device = '/device';
  static const String qrScanner = '/qr_scanner';
  static const String search = '/search';
  static const String addDevice = '/add_device';
  static const String addExistTaggedDevice = '/add_exist_tagged_device';
  static const String application = '/application';
  static const String addNewDevice = '/add_new_device';
  static const String addNewDeviceForm = '/add_new_device_form';

  // --- 路由映射表 ---
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      device: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return DeviceScreen(itemId: args?['itemId'] as String?);
      },
      application: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ApplicationScreen(rentId: args?['rentId'] as String?);
      },
      qrScanner: (context) => const QrScannerScreen(),
      search: (context) => const SearchScreen(),
      addDevice: (context) => const AddDeviceScreen(),
      addExistTaggedDevice: (context) => const AddExistTaggedDeviceScreen(),
      addNewDevice: (context) => const AddNewDeviceScreen(),
      addNewDeviceForm: (context) => const AddNewDeviceForm(),
    };
  }
}

// --- main 函数 ---
void main() async {
  // 4. 确保 Flutter 绑定已初始化 (异步操作前需要)
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- 数据源切换变量 ---
  // true: 使用示例数据，false: 使用真实API
  const bool useMockData = true; // ← 只需修改这里即可切换

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => DataService(
            dataSourceType: useMockData ? DataSourceType.mock : DataSourceType.api,
          ),
        ),
      ],
      child: const MyApp(),
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

      // onGenerateRoute 保持不变
      onGenerateRoute: (settings) {
        // 检查是否需要登录
        if (settings.name != AppRoutes.login) {
          final authService = Provider.of<AuthService>(context, listen: false);
          if (!authService.isLoggedIn) {
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
        }

        // 如果已登录或访问登录页面，使用正常路由
        final builder = AppRoutes.routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }

        // 处理未知路由
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('错误')),
            body: Center(
              child: Text('路由 ${settings.name} 未定义'),
            ),
          ),
        );
      },

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