import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/example_data.dart';

/// 数据源类型
enum DataSourceType { mock, api }

class DataService with ChangeNotifier {
  /// 实际服务器端点（请在此处填写真实服务器地址）
  static String apiBaseUrl = 'https://stocktaking.swagger.io/api/v3';

  /// 当前数据源类型
  DataSourceType dataSourceType;

  DataService({this.dataSourceType = DataSourceType.mock});

  // 切换数据源
  void switchDataSource(DataSourceType type) {
    dataSourceType = type;
    notifyListeners();
  }

  // 获取设备类型列表
  Future<List<ItemType>> getItemTypes() async {
    if (dataSourceType == DataSourceType.mock) {
      return exampleItemTypes;
    } else {
      // TODO: 实现真实API请求
      throw UnimplementedError('API请求未实现');
    }
  }

  // 获取设备状态列表
  Future<List<ItemStatus>> getItemStatuses() async {
    if (dataSourceType == DataSourceType.mock) {
      return exampleItemStatuses;
    } else {
      // TODO: 实现真实API请求
      throw UnimplementedError('API请求未实现');
    }
  }

  // 获取设备列表
  Future<List<Item>> getItems() async {
    if (dataSourceType == DataSourceType.mock) {
      return exampleItems;
    } else {
      // TODO: 实现真实API请求
      throw UnimplementedError('API请求未实现');
    }
  }

  // 获取用户列表
  Future<List<User>> getUsers() async {
    if (dataSourceType == DataSourceType.mock) {
      return exampleUsers;
    } else {
      // TODO: 实现真实API请求
      throw UnimplementedError('API请求未实现');
    }
  }

  // 获取租赁列表
  Future<List<Rent>> getRents() async {
    if (dataSourceType == DataSourceType.mock) {
      return exampleRents;
    } else {
      // TODO: 实现真实API请求
      throw UnimplementedError('API请求未实现');
    }
  }

  // 添加新设备
  Future<String?> addItem(Map<String, dynamic> itemData) async {
    if (dataSourceType == DataSourceType.mock) {
      // 模拟添加设备
      final newItem = Item(
        itemId: itemData['itemId'] ?? 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
        name: itemData['name'],
        location: itemData['location'],
        description: itemData['description'],
        type: ItemType.other, // 默认类型
        status: ItemStatus.available, // 默认状态
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      exampleItems.add(newItem);
      notifyListeners();
      return newItem.itemId;
    } else {
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/storage/inventory/item'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': itemData['name'],
            'type': 'other', // 默认类型
            'itemId': itemData['itemId'],
            'location': itemData['location'],
            'description': itemData['description'],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['itemid'];
        } else {
          print('添加设备失败: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('添加设备错误: $e');
        return null;
      }
    }
  }

  /// 获取单个设备信息
  Future<Item?> getItem(String itemId) async {
    if (dataSourceType == DataSourceType.mock) {
      try {
        return exampleItems.firstWhere(
          (item) => item.itemId == itemId,
        );
      } catch (e) {
        return null;
      }
    } else {
      try {
        final response = await http.get(
          Uri.parse('$apiBaseUrl/storage/inventory/item/$itemId'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return Item.fromJson(data);
        } else if (response.statusCode == 404) {
          return null; // 设备不存在
        } else {
          throw Exception('Failed to get item: ${response.statusCode}');
        }
      } catch (e) {
        print('Error getting item: $e');
        rethrow;
      }
    }
  }
} 