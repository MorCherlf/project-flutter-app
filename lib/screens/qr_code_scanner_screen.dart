import 'dart:io'; // 用于 Platform.isAndroid/isIOS

import 'package:flutter/material.dart';
import 'package:project/utils/haptics.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:project/services/data_service.dart';
import 'package:provider/provider.dart';

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
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// 提取二维码中的设备ID
  String? _extractDeviceId(String? code) {
    if (code == null) return null;
    final uri = Uri.tryParse(code);
    if (uri == null) return null;
    // 1. https://xxx.com/device/idxsxsxsxsx
    final devicePath = uri.pathSegments;
    if (devicePath.length >= 2 && devicePath[devicePath.length - 2] == 'device') {
      return devicePath.last;
    }
    // 2. https://xxx.com/xxxxx?deviceid=idxsxsxsxsx
    final deviceId = uri.queryParameters['deviceid'];
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }
    return null;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      _isProcessing = true;
      AppHaptics.mediumImpact();

      try {
        final deviceId = _extractDeviceId(scanData.code);
        if (deviceId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code format')),
          );
          return;
        }

        // 查找设备
        final dataService = Provider.of<DataService>(context, listen: false);
        final item = await dataService.getItem(deviceId);

        if (mounted) {
          if (item != null) {
            // 设备存在，跳转到设备详情页
            Navigator.pushNamed(
              context,
              '/device',
              arguments: {'itemId': deviceId},
            );
          } else {
            // 设备不存在，显示提示
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This device ID is not registered')),
            );
          }
        }
      } catch (e) {
        print('Error processing QR code: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error processing QR code')),
          );
        }
      } finally {
        _isProcessing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.deepPurple,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}