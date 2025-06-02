import 'dart:io'; // 用于 Platform.isAndroid/isIOS

import 'package:flutter/material.dart';
import 'package:project/utils/haptics.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

// --- 自定义 Painter 用于绘制扫描框覆盖层 ---
class ScannerOverlayPainter extends CustomPainter {
  final Radius scanWindowRadius; // 扫描框圆角
  final double scanAreaSize;     // 扫描区域边长
  final double topPercent;       // 扫描区域顶部距离画布顶部的百分比 (0.0 到 1.0)

  final Color overlayColor;      // 覆盖层颜色
  final Color borderColor;       // 扫描框边框颜色 (如果需要)
  final double borderWidth;       // 扫描框边框宽度
  final Color cornerColor;       // 四个角的颜色
  final double cornerLength;      // 四个角的长度
  final double cornerWidth;       // 四个角的线宽

  ScannerOverlayPainter({
    required this.scanWindowRadius,
    required this.scanAreaSize,
    required this.topPercent,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5), // 半透明黑色
    this.borderColor = Colors.transparent, // 默认边框透明
    this.borderWidth = 1.0,
    this.cornerColor = Colors.blue, // 默认蓝色角
    this.cornerLength = 20.0,
    this.cornerWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) { // 'size' 是 CustomPaint 画布的大小
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // --- 在 Painter 内部根据画布尺寸和参数计算扫描框 Rect ---
    final double left = (size.width - scanAreaSize) / 2; // 水平居中
    final double top = size.height * topPercent;         // 根据百分比计算顶部位置
    // 确保 top 不会小于 0 或导致矩形超出底部 (虽然可能性不大)
    final calculatedScanWindowRect = Rect.fromLTWH(
        left.clamp(0.0, size.width - scanAreaSize), // 防止超出左右边界
        top.clamp(0.0, size.height - scanAreaSize), // 防止超出上下边界
        scanAreaSize,
        scanAreaSize);
    // --- 计算结束 ---

    final scanWindowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(calculatedScanWindowRect, scanWindowRadius));

    // 创建挖掉扫描框区域的覆盖层路径
    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      scanWindowPath,
    );

    // 绘制半透明覆盖层
    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(overlayPath, overlayPaint);

    // (可选) 绘制扫描框边框
    if (borderWidth > 0 && borderColor != Colors.transparent) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(scanWindowPath, borderPaint);
    }

    // 绘制四个角
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    final double halfCornerWidth = cornerWidth / 2;
    final Path cornersPath = Path();

    // 使用 calculatedScanWindowRect 绘制四个角
    cornersPath.moveTo(calculatedScanWindowRect.left - halfCornerWidth, calculatedScanWindowRect.top + cornerLength);
    cornersPath.lineTo(calculatedScanWindowRect.left - halfCornerWidth, calculatedScanWindowRect.top - halfCornerWidth);
    cornersPath.lineTo(calculatedScanWindowRect.left + cornerLength, calculatedScanWindowRect.top - halfCornerWidth);
    cornersPath.moveTo(calculatedScanWindowRect.right + halfCornerWidth, calculatedScanWindowRect.top + cornerLength);
    cornersPath.lineTo(calculatedScanWindowRect.right + halfCornerWidth, calculatedScanWindowRect.top - halfCornerWidth);
    cornersPath.lineTo(calculatedScanWindowRect.right - cornerLength, calculatedScanWindowRect.top - halfCornerWidth);
    cornersPath.moveTo(calculatedScanWindowRect.left - halfCornerWidth, calculatedScanWindowRect.bottom - cornerLength);
    cornersPath.lineTo(calculatedScanWindowRect.left - halfCornerWidth, calculatedScanWindowRect.bottom + halfCornerWidth);
    cornersPath.lineTo(calculatedScanWindowRect.left + cornerLength, calculatedScanWindowRect.bottom + halfCornerWidth);
    cornersPath.moveTo(calculatedScanWindowRect.right + halfCornerWidth, calculatedScanWindowRect.bottom - cornerLength);
    cornersPath.lineTo(calculatedScanWindowRect.right + halfCornerWidth, calculatedScanWindowRect.bottom + halfCornerWidth);
    cornersPath.lineTo(calculatedScanWindowRect.right - cornerLength, calculatedScanWindowRect.bottom + halfCornerWidth);
    canvas.drawPath(cornersPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ScannerOverlayPainter) {
      return oldDelegate.scanAreaSize != scanAreaSize ||
          oldDelegate.topPercent != topPercent ||
          oldDelegate.scanWindowRadius != scanWindowRadius ||
          oldDelegate.overlayColor != overlayColor || // 也比较颜色等可能变化的参数
          oldDelegate.borderColor != borderColor ||
          oldDelegate.borderWidth != borderWidth ||
          oldDelegate.cornerColor != cornerColor ||
          oldDelegate.cornerLength != cornerLength ||
          oldDelegate.cornerWidth != cornerWidth;
    }
    return false;
  }
}
// --- Painter 结束 ---


// --- 扫描屏幕 Widget ---
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR'); // 用于 QRView 的 Key
  QRViewController? controller; // QRView 的控制器
  Barcode? result; // 存储扫描结果
  bool _isProcessing = false; // 防止重复处理标志
  bool _isFlashOn = false; // 闪光灯状态

  @override
  void initState() {
    super.initState();
    // 注意：这里不再显式检查权限，依赖插件或系统的默认行为
  }

  // 应对热重载或特殊情况下的相机暂停/恢复
  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera(); // Android 上建议先暂停
      }
      controller!.resumeCamera(); // 恢复相机以继续扫描
    }
  }

  @override
  void dispose() {
    controller?.dispose(); // 页面销毁时必须销毁控制器
    super.dispose();
  }

  // AppBar 返回按钮事件
  void _onBackPressed() {
    AppHaptics.mediumImpact();
    Navigator.of(context).pop();
  }

  // QRView 创建完成的回调
  void _onQRViewCreated(QRViewController controller) {
    print('[DEBUG] QRView created!'); // 调试信息
    setState(() {
      this.controller = controller;
    });
    _updateFlashStatus(); // 获取并更新初始闪光灯状态

    // 监听扫描数据流
    controller.scannedDataStream.listen((scanData) {
      if (_isProcessing) return; // 如果正在处理上一个结果，则忽略

      // 检查扫描到的数据和类型
      print(
          '[DEBUG] Scanned data: ${scanData.code}, Format: ${scanData.format}');

      // 由于我们设置了 formatsAllowed: [BarcodeFormat.qrcode]，理论上这里只会收到 qrcode 类型
      // 但仍可以加一层保险判断
      if (scanData.format == BarcodeFormat.qrcode && scanData.code != null &&
          scanData.code!.isNotEmpty) {
        setState(() {
          _isProcessing = true;
          result = scanData;
        });

        AppHaptics.heavyImpact(); // 成功反馈
        print('[DEBUG] QR Code Detected: ${result?.code}');

        controller.pauseCamera(); // 暂停相机，防止连续扫描

        // 显示结果对话框
        showDialog(
          context: context,
          barrierDismissible: false, // 不允许点击外部关闭
          builder: (context) =>
              AlertDialog(
                title: const Text('扫描结果'),
                content: Text('内容: ${result?.code}'),
                actions: [
                  TextButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                      Navigator.of(context).pop(result?.code); // 返回结果到上一个页面
                    },
                  ),
                  TextButton(
                    child: const Text('再扫一次'),
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭对话框
                      controller.resumeCamera(); // 恢复相机扫描
                      setState(() {
                        _isProcessing = false;
                      }); // 允许再次处理
                    },
                  ),
                ],
              ),
        ).then((_) {
          // 如果对话框因其他原因关闭（例如按物理返回键，如果允许的话）
          // 确保状态被重置，以防卡在 _isProcessing = true
          // 由于 barrierDismissible = false，主要依赖按钮来重置状态
          if (mounted && _isProcessing) {
            print(
                "[DEBUG] Dialog closed unexpectedly? Resetting processing state.");
            controller.resumeCamera(); // 确保相机恢复
            setState(() {
              _isProcessing = false;
            });
          }
        });
      } else {
        print('[DEBUG] Ignoring detected barcode (Format: ${scanData.format})');
      }
    });
  }

  // 获取并更新闪光灯状态
  Future<void> _updateFlashStatus() async {
    bool? flashStatus = await controller?.getFlashStatus();
    // 检查 widget 是否还在树中，避免 setState 错误
    if (mounted && flashStatus != null) {
      setState(() {
        _isFlashOn = flashStatus;
      });
    }
  }

  // 切换闪光灯
  Future<void> _toggleFlash() async {
    AppHaptics.lightImpact();
    await controller?.toggleFlash();
    await Future.delayed(const Duration(milliseconds: 150)); // 等待 150 毫秒
    if (!mounted) return;
    AppHaptics.heavyImpact();
    _updateFlashStatus(); // 请求切换后更新状态
  }

  @override
  Widget build(BuildContext context) {
    // --- 计算尺寸和位置参数 ---
    final screenRect = MediaQuery
        .of(context)
        .size;
    final screenWidth = screenRect.width;

    // 视觉扫描框的大小和圆角
    final double visualScanAreaSize = screenWidth * 0.7;
    const double scanAreaRadius = 20.0;

    // 视觉扫描框顶部距离 Body 顶部的百分比 (Painter 会用到)
    final double topVisualPercent = 0.3; // 保持视觉位置偏上

    // (可选) 尝试增大逻辑扫描区域大小 (可以保留这个尝试)
    final double logicalScanAreaSize = visualScanAreaSize * 1.25; // 尝试增大 5%


    // --- UI 构建 ---
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // ... (AppBar 保持不变) ...
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _onBackPressed,
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : Colors.white,
            ),
            tooltip: '闪光灯',
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            formatsAllowed: const [BarcodeFormat.qrcode],
            // *** 关键修改：移除了 cutOutBottomOffset ***
            overlay: QrScannerOverlayShape(
              borderColor: Colors.transparent,
              borderRadius: 0,
              borderLength: 0,
              borderWidth: 0,
              cutOutSize: logicalScanAreaSize,
            ),
            onPermissionSet: (ctrl, p) {
              print('[DEBUG] QRView onPermissionSet: $p');
              if (!p && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('没有相机权限！')),
                );
              }
            },
          ),
          // CustomPaint 绘制视觉扫描框 (位置仍然是偏上)
          CustomPaint(
            size: Size.infinite,
            painter: ScannerOverlayPainter(
              scanAreaSize: visualScanAreaSize, // 视觉大小
              topPercent: topVisualPercent, // 视觉位置
              scanWindowRadius: Radius.circular(scanAreaRadius),
            ),
          ),
        ],
      ),
    );
  }
}