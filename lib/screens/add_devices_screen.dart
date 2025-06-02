import 'package:flutter/material.dart';
import 'package:project/utils/haptics.dart';

import '../main.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  // 处理返回按钮点击事件
  void _onBackPressed(BuildContext context) {
    AppHaptics.mediumImpact(); // 添加震动反馈
    Navigator.of(context).pop();
  }

  // 处理 "Add New Device" 点击事件
  void _navigateToAddManual(BuildContext context) {
    AppHaptics.lightImpact(); // 添加震动反馈
    print('Navigate to Add New Device Manually Screen');
    // TODO: 在这里实现导航到手动添加设备页面的逻辑
    // 例如: Navigator.pushNamed(context, AppRoutes.addManualDevice);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Navigate to Add New Device')),
    );
  }

  // 处理 "Add Exist Tagged Device" 点击事件
  void _navigateToAddTagged(BuildContext context) {
    AppHaptics.lightImpact(); // 添加震动反馈
    Navigator.of(context).pushNamed(AppRoutes.addExistTaggedDevice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0, // 移除阴影
        scrolledUnderElevation: 0, // 滚动时也不显示阴影
        leading: IconButton( // 返回按钮
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 黑色图标
          tooltip: 'Back', // 可选：增加提示
          onPressed: () => _onBackPressed(context), // 调用返回处理函数
        ),
        title: const Text( // 标题
          'Add Devices',
          style: TextStyle(
              color: Colors.black, // 黑色标题
              fontWeight: FontWeight.bold // 字体加粗 (如果需要)
          ),
        ),
        centerTitle: false, // 标题居左对齐
      ),
      body: Column( // 使用 Column 将列表项放在顶部
        children: <Widget>[
          // 第一个列表项: Add New Device
          ListTile(
            title: const Text('Add New Device'), // 列表项标题
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]), // 右侧箭头图标
            onTap: () => _navigateToAddManual(context), // 点击事件处理
            // contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 可选：调整内边距
            // visualDensity: VisualDensity.compact, // 可选：调整紧凑度
          ),
          // 第一个分隔线
          const Divider(
            height: 1,        // 分隔线占据的垂直空间（设为1使其紧凑）
            thickness: 1,     // 分隔线的粗细
            color: Color(0xFFEEEEEE), // 分隔线颜色 (浅灰色，可调整)
            indent: 0,        // 左侧缩进 (0表示全宽)
            endIndent: 0,     // 右侧缩进 (0表示全宽)
          ),
          // 第二个列表项: Add Exist Tagged Device
          ListTile(
            title: const Text('Add Exist Tagged Device'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () => _navigateToAddTagged(context),
            // contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // 第二个分隔线
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEEEEEE),
            indent: 0,
            endIndent: 0,
          ),
          // 列表项结束
          // 如果希望列表项下方有更多空间，可以在这里添加 SizedBox 或 Spacer
          // const SizedBox(height: 20),
          // const Spacer(), // 如果希望将列表项推到最顶部，填满剩余空间
        ],
      ),
    );
  }
}