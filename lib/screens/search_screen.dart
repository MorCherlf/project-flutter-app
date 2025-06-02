import 'package:flutter/material.dart';

import '../utils/haptics.dart';

// --- SearchResultItem 类定义 ---
class SearchResultItem {
  final String id;
  final String title;
  final String overline;
  final String type;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.overline,
    required this.type,
  });
}
// --- 类定义结束 ---

// --- 示例数据 (如果未导入) ---
final List<SearchResultItem> _allItems = [
  SearchResultItem(id: 'd001', title: '我的智能设备', overline: '客厅', type: 'device'),
  SearchResultItem(id: 'd002', title: '智能灯泡 X', overline: '卧室', type: 'device'),
  SearchResultItem(id: 'd003', title: '温控器 Z', overline: '客厅', type: 'device'),
  SearchResultItem(id: 'a001', title: '安装申请单', overline: '待审核', type: 'application'),
  SearchResultItem(id: 'd004', title: '前门摄像头', overline: '入口', type: 'device'),
  SearchResultItem(id: 'a002', title: '维修工单', overline: '处理中', type: 'application'),
  SearchResultItem(id: 'd005', title: '大门智能锁', overline: '入口', type: 'device'),
  SearchResultItem(id: 's001', title: '用户偏好设置', overline: '系统设置', type: 'setting'),
  SearchResultItem(id: 'd006', title: '厨房顶灯', overline: '厨房', type: 'device'),
  SearchResultItem(id: 'a003', title: '服务单 #12345', overline: '已完成', type: 'application'),
];
// --- 示例数据结束 ---


// 搜索页面 Widget
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 搜索框的文本控制器
  final TextEditingController _searchController = TextEditingController();
  // 用于存储过滤后结果的列表
  List<SearchResultItem> _filteredItems = [];
  // 控制清除按钮是否显示
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // 初始化时，显示所有项目（或根据需求保持为空直到用户开始搜索）
    _filteredItems = List.from(_allItems); // 初始显示所有项目
    // 为搜索控制器添加监听器，以便在文本变化时触发搜索
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // 移除监听器以防止内存泄漏
    _searchController.removeListener(_onSearchChanged);
    // 释放控制器资源
    _searchController.dispose();
    super.dispose();
  }

  void _onBackPressed() {
    AppHaptics.mediumImpact();
    Navigator.of(context).pop();
  }

  // 当搜索框文本发生变化时调用
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase(); // 获取查询文本并转为小写，实现不区分大小写搜索
    setState(() {
      // 根据输入框是否有内容，决定是否显示清除按钮
      _showClearButton = query.isNotEmpty;
      if (query.isEmpty) {
        // 如果查询为空，重置列表以显示所有项目
        _filteredItems = List.from(_allItems);
      } else {
        // 根据查询过滤项目 (匹配 title 或 overline)
        _filteredItems = _allItems.where((item) {
          final titleMatch = item.title.toLowerCase().contains(query);
          final overlineMatch = item.overline.toLowerCase().contains(query);
          // 如果 title 或 overline 包含查询文本，则保留该项目
          return titleMatch || overlineMatch;
        }).toList();
      }
    });
  }

  // 清除搜索框内容的方法
  void _clearSearch() {
    AppHaptics.lightImpact();
    _searchController.clear();
    // 注意：调用 clear() 后，监听器会自动触发 _onSearchChanged 方法更新列表
  }

  // 构建列表项前面的占位图标 (根据你的图片)
  Widget _buildLeadingIconPlaceholder() {
    // 复现图片中的图标样式
    return Container(
      width: 40, // 根据需要调整大小
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300], // 占位背景色
        // borderRadius: BorderRadius.circular(8), // 可选：如果需要圆角
      ),
      child: Stack( // 使用 Stack 组合图标
        alignment: Alignment.center,
        children: [
          Icon(Icons.square_outlined, color: Colors.grey[600], size: 24), // 方形轮廓
          Positioned( // 左上角圆形
            top: 4,
            left: 4,
            child: Icon(Icons.circle_outlined, color: Colors.grey[600], size: 10),
          ),
          Positioned( // 右下角三角形
            bottom: 4,
            right: 4,
            child: Icon(Icons.change_history_outlined, color: Colors.grey[600], size: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 获取当前主题数据，方便下面使用

    return Scaffold(
      appBar: AppBar(
        // 返回按钮
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed, // 点击时返回上一页
        ),
        // 将 TextField 放置在 AppBar 的 title 位置
        title: TextField(
          controller: _searchController, // 关联控制器
          autofocus: true, // 自动获取焦点并弹出键盘
          decoration: const InputDecoration(
            hintText: 'Search', // 输入框提示文字
            border: InputBorder.none, // 移除边框/下划线
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey), // 提示文字样式
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16), // 输入文字样式
          cursorColor: theme.colorScheme.primary, // 光标颜色使用主题色
        ),
        // AppBar 右侧的操作按钮
        actions: [
          // 条件性显示清除按钮：仅当 _showClearButton 为 true 时显示
          if (_showClearButton)
            IconButton(
              icon: const Icon(Icons.close), // 清除图标
              onPressed: _clearSearch, // 点击时调用清除方法
            )
          else
          // 当清除按钮不显示时，添加一个占位 SizedBox 保持 AppBar 高度或右侧间距一致
            const SizedBox(width: 48), // IconButton 默认宽度是 48
        ],
        // 可以根据需要设置 AppBar 的背景色、阴影等
        // backgroundColor: Colors.white,
        // elevation: 1,
      ),
      // 页面主体内容
      body: _filteredItems.isEmpty // 判断过滤结果是否为空
          ? Center( // 如果为空，显示提示信息
        child: Text(
          _searchController.text.isEmpty
              ? 'Input to search' // 搜索框为空时的提示
              : 'Cannot found the result', // 搜索后无匹配结果时的提示
          style: TextStyle(color: Colors.grey[600]),
        ),
      )
          : ListView.separated( // 如果有结果，使用带分隔线的列表显示
        itemCount: _filteredItems.length, // 列表项数量
        itemBuilder: (context, index) { // 构建每个列表项
          final item = _filteredItems[index]; // 获取当前项的数据
          return ListTile(
            leading: _buildLeadingIconPlaceholder(), // 使用前面定义的占位图标
            title: Text( // 第一行小字 (Overline)
              item.overline,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]), // 使用小号字体和灰色
            ),
            subtitle: Text( // 第二行主标题 (Title)
              item.title,
              style: theme.textTheme.titleMedium, // 使用中号标题字体
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey), // 右侧箭头图标
            onTap: () { // 列表项点击事件
              // AppHaptics.lightImpact(); // 可选：添加触感反馈
              print('Clicked:  ${item.title} (ID: ${item.id})');
              // TODO: 在这里实现点击列表项后的操作，例如导航到详情页
              // Navigator.pushNamed(context, '/details', arguments: item.id);
            },
          );
        },
        separatorBuilder: (context, index) { // 构建分隔线
          // 添加分隔线样式，与图片一致
          return const Divider(
            height: 1, // 分隔线高度（视觉上是间距）
            thickness: 1, // 分割线粗细
            indent: 72, // 左侧缩进，大致与文字对齐（leading 图标宽度 + 间距）
            endIndent: 16, // 可选：右侧缩进
          );
        },
      ),
    );
  }
}