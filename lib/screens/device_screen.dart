import 'package:flutter/material.dart';
import 'package:project/widgets/float_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:project/services/data_service.dart';
import 'package:project/models/item.dart';
import 'package:project/models/rent.dart';

import '../utils/haptics.dart';

class DeviceScreen extends StatefulWidget {
  final String? itemId;
  
  const DeviceScreen({
    super.key,
    this.itemId,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  Item? _currentItem;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final items = await dataService.getItems();
    final targetItemId = widget.itemId ?? (items.isNotEmpty ? items[0].itemId : null);
    
    if (targetItemId != null) {
      setState(() {
        _currentItem = items.firstWhere(
          (item) => item.itemId == targetItemId,
          orElse: () => items.first,
        );
      });
    }
  }

  void _onItemTapped(int index) {
    AppHaptics.mediumImpact();
    setState(() {
      _selectedIndex = index;
    });
    // 在这里处理导航逻辑
    if (index == 0) {
      print('Detail tapped');
    } else if (index == 1) {
      print('Applications tapped');
    }
  }

  Widget _buildDetailTab(Item? item) {
    if (item == null) {
      return const Center(child: Text('设备信息不存在'));
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.crop_square, size: 48, color: Colors.grey[600]),
                Icon(Icons.circle_outlined, size: 48, color: Colors.grey[600]),
                Icon(Icons.play_arrow, size: 48, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '设备ID: ${item.itemId}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            '位置: ${item.location ?? "未设置"}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '状态: ${item.status.name}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '类型: ${item.type.name}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            '设备描述',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            item.description ?? '暂无描述',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab(List<Rent> rents) {
    final theme = Theme.of(context);
    if (rents.isEmpty) {
      return const Center(child: Text('暂无租赁申请'));
    }
    
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rents.length,
            itemBuilder: (context, index) {
              final rent = rents[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: Text(rent.userId.toString()[0]),
                ),
                title: Text(rent.rentStatus?.name ?? '未知状态'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('申请人ID: ${rent.userId}'),
                    Text(
                      '申请时间: ${rent.startDate ?? "未知"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  print('Tapped on rent application ${rent.rentId}');
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    if (_currentItem == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<List<Rent>>(
      future: dataService.getRents(),
      builder: (context, rentSnapshot) {
        if (rentSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('加载租赁信息失败: ${rentSnapshot.error}'),
            ),
          );
        }
        
        if (rentSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final rents = rentSnapshot.data?.where((r) => r.itemId.toString() == _currentItem!.itemId).toList() ?? [];
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 150.0,
                    floating: false,
                    pinned: true,
                    leading: const BackButton(),
                    actions: const [
                      Icon(Icons.redo),
                      SizedBox(width: 20),
                      Icon(Icons.calendar_today_outlined),
                      SizedBox(width: 20),
                      Icon(Icons.more_vert),
                      SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        _currentItem?.name ?? '设备详情',
                        style: const TextStyle(fontSize: 18),
                      ),
                      centerTitle: false,
                      background: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _selectedIndex == 0 ? _buildDetailTab(_currentItem) : _buildApplicationsTab(rents),
                    ]),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 36.0),
                  child: FloatNavigationBar(
                    items: const [
                      FloatNavigationBarItem(
                        icon: Icons.info,
                        activeIcon: Icons.info_outline,
                        label: 'Detail',
                      ),
                      FloatNavigationBarItem(
                        icon: Icons.apps,
                        activeIcon: Icons.apps_outlined,
                        label: 'Applications',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}