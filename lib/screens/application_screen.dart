import 'package:flutter/material.dart';
import 'package:project/widgets/float_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:project/services/data_service.dart';
import 'package:project/models/item.dart';
import 'package:project/models/rent.dart';

import '../utils/haptics.dart';

class ApplicationScreen extends StatefulWidget {
  final String? rentId;
  
  const ApplicationScreen({
    super.key,
    this.rentId,
  });

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  Rent? _currentRent;
  Item? _relatedItem;

  @override
  void initState() {
    super.initState();
    _loadApplicationData();
  }

  Future<void> _loadApplicationData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final rents = await dataService.getRents();
    final targetRentId = widget.rentId != null ? int.tryParse(widget.rentId!) : null;
    
    if (targetRentId != null) {
      final rent = rents.firstWhere(
        (r) => r.rentId == targetRentId,
        orElse: () => rents.first,
      );
      
      // 加载关联的设备信息
      final items = await dataService.getItems();
      final relatedItem = items.firstWhere(
        (item) => item.itemId == rent.itemId.toString(),
        orElse: () => items.first,
      );
      
      setState(() {
        _currentRent = rent;
        _relatedItem = relatedItem;
      });
    }
  }

  void _onItemTapped(int index) {
    AppHaptics.mediumImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDetailTab(Rent? rent, Item? item) {
    if (rent == null) {
      return const Center(child: Text('申请信息不存在'));
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
                Icon(Icons.stop_outlined, size: 48, color: Colors.grey[600]),
                Icon(Icons.circle_outlined, size: 48, color: Colors.grey[600]),
                Icon(Icons.change_history_outlined, size: 48, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '租赁申请 #${rent.rentId}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '状态: ${rent.rentStatus?.name ?? "未知"}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            '申请信息',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('申请人ID: ${rent.userId}'),
          Text('开始时间: ${rent.startDate ?? "未设置"}'),
          Text('结束时间: ${rent.endDate ?? "未设置"}'),
          Text('是否预约: ${rent.isBooking == true ? "是" : "否"}'),
          const SizedBox(height: 16),
          const Text(
            '关联设备',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (item != null) ...[
            Text('设备名称: ${item.name}'),
            Text('设备ID: ${item.itemId}'),
            Text('位置: ${item.location ?? "未设置"}'),
            Text('状态: ${item.status?.name ?? "未知"}'),
          ] else
            const Text('未找到关联设备信息'),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(Rent? rent) {
    if (rent == null) {
      return const Center(child: Text('申请信息不存在'));
    }
    
    // 这里可以添加申请历史记录的逻辑
    return const Center(
      child: Text('历史记录功能开发中...'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRent == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    '申请 #${_currentRent!.rentId}',
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
                  _selectedIndex == 0 
                    ? _buildDetailTab(_currentRent, _relatedItem)
                    : _buildHistoryTab(_currentRent),
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
                    icon: Icons.history,
                    activeIcon: Icons.history_outlined,
                    label: 'History',
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
  }
} 