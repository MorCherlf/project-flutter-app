import 'package:flutter/services.dart'; // 导入服务包

/// 应用全局触觉反馈工具类
class AppHaptics {
  /// 提供轻微的触觉反馈。通常用于选择变化或微小交互。
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// 提供中等的触觉反馈。适合按钮按下等标准交互。
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// 提供强烈的触觉反馈。用于重要事件或完成操作。
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// 提供选择变化的触觉反馈（例如滚动选择器）。
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// 触发设备标准的震动模式 (效果因平台而异)。
  /// 注意：这个可能比 impact 系列更长或模式不同。
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}