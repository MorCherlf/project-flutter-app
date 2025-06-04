import 'package:flutter/material.dart';
import 'package:project/utils/haptics.dart';
import '../main.dart';
import '../widgets/badged_icon.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/item.dart';
import '../models/rent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _bottomNavIndex = 0;
  late TabController _devicesTabController;
  late TabController _applicationsTabController;

  final List<String> _tabs = ["All", "Review", "Process", "Complete", "Repair"];
  final List<int> _reviewBadgeCounts = [0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _devicesTabController = TabController(length: _tabs.length, vsync: this);
    _applicationsTabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _devicesTabController.dispose();
    _applicationsTabController.dispose();
    super.dispose();
  }

  void _onBottomNavItemTapped(int index) {
    AppHaptics.mediumImpact();
    setState(() {
      _bottomNavIndex = index;
      if (index == 1) {
        _applicationsTabController.animateTo(0);
      } else if (index == 0) {
        _devicesTabController.animateTo(0);
      }
    });
    print("Bottom nav tapped: $index");
  }

  void _onFabPressed() {
    AppHaptics.lightImpact();
    Navigator.pushNamed(context, AppRoutes.addDevice);
  }

  void _onSearchPressed() {
    AppHaptics.lightImpact();
    Navigator.pushNamed(context, AppRoutes.search);
  }

  void _onScannerPressed() {
    AppHaptics.lightImpact();
    Navigator.pushNamed(context, AppRoutes.qrScanner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 顶部 App Bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: _onSearchPressed,
        ),
        title: const Text(
          'Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            onPressed: _onScannerPressed,
          ),
        ],
        bottom: _bottomNavIndex == 0
            ? TabBar(
          controller: _devicesTabController,
          isScrollable: true,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
          tabAlignment: TabAlignment.center,
        )
            : null,
      ),

      // Body部分选择器
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          DevicesScreen(tabController: _devicesTabController, tabs: _tabs),
          ApplicationsScreen(tabController: _applicationsTabController, tabs: _tabs, reviewBadgeCounts: _reviewBadgeCounts),
          const SystemScreen(),
        ],
      ),

      // 浮动添加设备按钮
      floatingActionButton: _bottomNavIndex == 0
          ? FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      )
          : null, // 当不在 DevicesScreen 时，返回 null 隐藏 FAB

      // 底部导航栏
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: _onBottomNavItemTapped,
        destinations: const <Widget>[
          // 设备导航
          NavigationDestination(
            selectedIcon: Icon(Icons.devices_other),
            icon: Icon(Icons.devices_other_outlined),
            label: 'Devices',
          ),

          // 申请表导航
          NavigationDestination(
            icon: BadgedIcon(icon: Icons.inbox_outlined, badgeCount: 0,),
            selectedIcon: BadgedIcon(icon: Icons.inbox, badgeCount: 0,),
            label: 'Applications',
          ),

          // 系统导航
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'System',
          ),
        ],
      ),
    );
  }
}

// 设备页面
class DevicesScreen extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const DevicesScreen({super.key, required this.tabController, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataService = Provider.of<DataService>(context, listen: false);
    return FutureBuilder<List<Item>>(
      future: dataService.getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        return TabBarView(
          controller: tabController,
          children: tabs.map((String name) {
            return ListView.separated(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[300],
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.square_outlined, color: Colors.grey, size: 30),
                        Positioned(
                          top: 5, left: 5,
                          child: Icon(Icons.circle_outlined, color: Colors.grey, size: 15),
                        ),
                        Positioned(
                          bottom: 5, right: 5,
                          child: Icon(Icons.change_history_outlined, color: Colors.grey, size: 15),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  subtitle: Text(
                    item.location ?? '',
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    print('Tapped on item: \\${item.name}');
                    AppHaptics.mediumImpact();
                    Navigator.pushNamed(
                      context,
                      AppRoutes.device,
                      arguments: {'itemId': item.itemId},
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  indent: 72,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// 申请表页面
class ApplicationsScreen extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final List<int> reviewBadgeCounts;

  const ApplicationsScreen({super.key, required this.tabController, required this.tabs, required this.reviewBadgeCounts});

  Widget _buildApplicationsTabContent(BuildContext context, String tabName, List<Rent> rents) {
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: rents.length,
      itemBuilder: (context, index) {
        final rent = rents[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            color: Colors.grey[300],
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.stop_outlined, color: Colors.grey[400], size: 30),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Icon(Icons.circle, color: Colors.grey[400], size: 15),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Icon(Icons.change_history_outlined, color: Colors.grey[400], size: 15),
                ),
              ],
            ),
          ),
          title: Text(
            tabName,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('租赁ID: \\${rent.rentId}'),
              Text(
                '设备ID: \\${rent.itemId}，用户ID: \\${rent.userId}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: const Icon(Icons.play_arrow, color: Colors.grey),
          onTap: () {
            print('Tapped on rentId: \\${rent.rentId}');
            AppHaptics.mediumImpact();
            Navigator.pushNamed(
              context,
              AppRoutes.application,
              arguments: {'rentId': rent.rentId.toString()},
            );
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataService = Provider.of<DataService>(context, listen: false);
    return FutureBuilder<List<Rent>>(
      future: dataService.getRents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rents = snapshot.data ?? [];
        return Column(
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabs: tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final name = entry.value;
                return Tab(
                  child: name == 'All'
                      ? Text(name)
                      : reviewBadgeCounts[index] > 0
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          reviewBadgeCounts[index].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                      : Text(name),
                );
              }).toList(),
              tabAlignment: TabAlignment.center,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: tabs.map((String name) {
                  return _buildApplicationsTabContent(context, name, rents);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 设置页面
class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('System Screen Content'),
    );
  }
}