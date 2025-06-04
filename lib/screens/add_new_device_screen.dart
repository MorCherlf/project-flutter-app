import 'package:flutter/material.dart';
import 'package:project/utils/haptics.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:project/screens/add_new_device_form.dart';
import 'dart:io';

class AddNewDeviceScreen extends StatefulWidget {
  const AddNewDeviceScreen({super.key});

  @override
  State<AddNewDeviceScreen> createState() => _AddNewDeviceScreenState();
}

class _AddNewDeviceScreenState extends State<AddNewDeviceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (_isProcessing) return;
      if (scanData.format == BarcodeFormat.qrcode && scanData.code != null && scanData.code!.isNotEmpty) {
        final id = _extractDeviceId(scanData.code!);
        if (id == null || id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code content, no device ID found')),
          );
          return;
        }
        setState(() {
          _isProcessing = true;
        });
        AppHaptics.heavyImpact();
        controller.pauseCamera();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddNewDeviceForm(qrCodeData: id),
          ),
        );
      }
    });
  }

  /// 提取二维码中的设备ID
  String? _extractDeviceId(String code) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Device QR Code'),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            formatsAllowed: const [BarcodeFormat.qrcode],
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 12,
              borderLength: 32,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'Put the QR code in the box',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
