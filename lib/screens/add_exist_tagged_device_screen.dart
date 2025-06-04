import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart'; // 导入 Camera 包
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'; // 导入条码扫描
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // 导入文本识别
import 'package:path/path.dart' show join; // 导入 path 包的方法
import 'package:path_provider/path_provider.dart'; // 导入 path_provider
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理器
import 'package:project/utils/haptics.dart';
import 'package:image_picker/image_picker.dart';

import 'add_exist_tagged_device_form.dart'; // 确保 Haptics 工具类路径正确


class AddExistTaggedDeviceScreen extends StatefulWidget {
  const AddExistTaggedDeviceScreen({super.key});

  @override
  State<AddExistTaggedDeviceScreen> createState() => _AddExistTaggedDeviceScreenState();
}

class _AddExistTaggedDeviceScreenState extends State<AddExistTaggedDeviceScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false; // 防止重复处理
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();

  // ML Kit 实例
  final BarcodeScanner _barcodeScanner =
  BarcodeScanner(formats: [BarcodeFormat.qrCode]); // 只配置扫描 QR Code
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin); // 配置识别拉丁字母 (英文等)
  // 如果需要识别中文，改为: TextRecognizer(script: TextRecognitionScript.chinese);
  // 注意：中文模型较大，可能需要按需下载或打包

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera(); // 初始化相机
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose(); // 销毁相机控制器
    _barcodeScanner.close();      // 关闭 ML Kit 扫描器
    _textRecognizer.close();      // 关闭 ML Kit 识别器
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // 初始化相机和权限检查
  Future<void> _initializeCamera() async {
    // 1. 检查权限
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = '相机权限未授予';
        });
        print('[ERROR] Camera permission not granted.');
        return;
      }
    }

    // 2. 获取可用相机
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = '未找到可用相机';
      });
      print('[ERROR] No available cameras found.');
      return;
    }

    // 3. 创建并初始化 CameraController
    // 通常使用第一个相机 (后置)
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high, // 使用较高分辨率以提高识别率
      enableAudio: false, // 不需要音频
      imageFormatGroup: Platform.isAndroid // 安卓上推荐 YUV420
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888, // iOS 推荐 BGRA8888
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return; // 异步操作后检查 mounted
      setState(() {
        _isCameraInitialized = true;
        _errorMessage = null; // 清除之前的错误信息
      });
      print('[INFO] Camera initialized successfully.');
    } on CameraException catch (e) {
      setState(() {
        _errorMessage = '相机初始化失败: ${e.code}\n${e.description}';
      });
      print('[ERROR] Failed to initialize camera: $e');
    } catch (e) {
      setState(() {
        _errorMessage = '发生未知错误: $e';
      });
      print('[ERROR] Unknown error initializing camera: $e');
    }
  }

  // 拍照并处理
  Future<void> _captureAndProcess() async {
    if (!_isCameraInitialized || _cameraController == null || _isProcessing) {
      print('[WARN] Camera not ready or already processing.');
      return;
    }

    setState(() { _isProcessing = true; });
    AppHaptics.mediumImpact(); // 拍照震动

    try {
      // 1. 拍照
      // 确保相机没有在处理图像流 (如果之前有启动的话，先停止)
      // await _cameraController.stopImageStream();
      final XFile imageFile = await _cameraController!.takePicture();
      print('[INFO] Picture taken: ${imageFile.path}');

      // 2. 准备 ML Kit 输入图像
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // 3. 执行条码扫描和文本识别 (可以并行执行)
      final Future<List<Barcode>> barcodeFuture = _barcodeScanner.processImage(inputImage);
      final Future<RecognizedText> textFuture = _textRecognizer.processImage(inputImage);

      // 等待两个任务完成
      final results = await Future.wait([barcodeFuture, textFuture]);

      // 4. 处理结果
      final List<Barcode> barcodes = results[0] as List<Barcode>;
      final RecognizedText recognizedText = results[1] as RecognizedText;

      String? qrData;
      if (barcodes.isNotEmpty) {
        // 查找第一个 QR Code 类型的结果
        final qrCode = barcodes.firstWhere(
                (barcode) => barcode.format == BarcodeFormat.qrCode,
            orElse: () => barcodes.first); // 如果没找到 QR，就取第一个（虽然我们配置了只扫QR）
        qrData = _extractDeviceId(qrCode.rawValue);
        print('[INFO] QR Code detected: $qrData');
      } else {
        print('[INFO] No QR Code detected.');
      }

      final String ocrText = recognizedText.text;
      print('[INFO] Text detected: $ocrText');

      // 5. 导航到表单页面并传递数据
      if (mounted) { // 再次检查 mounted
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddExistTaggedDeviceForm( // 跳转到你的表单页
              qrCodeData: qrData, // 只传递设备ID (可能为 null)
              recognizedText: ocrText, // 传递识别文本 (可能为空字符串)
            ),
          ),
        );
      }

    } catch (e) {
      print('[ERROR] Error during capture/processing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: ${e.toString()}')),
        );
      }
    } finally {
      // 确保处理标志被重置
      if (mounted) {
        setState(() { _isProcessing = false; });
      }
    }
  }

  // 从相册选择图片并处理
  Future<void> _pickAndProcessImage() async {
    if (_isProcessing) return;

    AppHaptics.mediumImpact(); // 震动

    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });
      AppHaptics.mediumImpact();

      // 准备 ML Kit 输入图像
      final InputImage inputImage = InputImage.fromFilePath(image.path);

      // 执行条码扫描和文本识别
      final Future<List<Barcode>> barcodeFuture = _barcodeScanner.processImage(inputImage);
      final Future<RecognizedText> textFuture = _textRecognizer.processImage(inputImage);

      final results = await Future.wait([barcodeFuture, textFuture]);

      final List<Barcode> barcodes = results[0] as List<Barcode>;
      final RecognizedText recognizedText = results[1] as RecognizedText;

      String? qrData;
      if (barcodes.isNotEmpty) {
        final qrCode = barcodes.firstWhere(
          (barcode) => barcode.format == BarcodeFormat.qrCode,
          orElse: () => barcodes.first,
        );
        qrData = _extractDeviceId(qrCode.rawValue);
        print('[INFO] QR Code detected from image: $qrData');
      }

      final String ocrText = recognizedText.text;
      print('[INFO] Text detected from image: $ocrText');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddExistTaggedDeviceForm(
              qrCodeData: qrData,
              recognizedText: ocrText,
            ),
          ),
        );
      }
    } catch (e) {
      print('[ERROR] Error during image processing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // --- UI 构建 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Exist Tagged Device'),
        backgroundColor: Colors.white, // 或主题色
        foregroundColor: Colors.black, // 图标和文字颜色
        elevation: 1,
        centerTitle: false, // 标题居左
      ),
      body: Column(
        children: [
          // 指示文字
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Make Sure the QR Code Sticker and the existed tag in the same place',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
          // 相机预览区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center( // 使预览居中（如果它没有填满 Expanded）
                child: _buildCameraPreview(),
              ),
            ),
          ),
          // 显示处理状态
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Identifying..."),
                ],
              ),
            )
          else if (_errorMessage != null) // 显示错误信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          else // 处理按钮只在相机就绪且未处理时显示
            const SizedBox(height: 72), // 占位，保持底部按钮位置相对稳定
        ],
      ),
      // 将拍照按钮放在底部中间 (使用 FloatingActionButton 或 Stack 定位)
      // 这里使用 FloatingActionButtonLocation 实现类似效果
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized && !_isProcessing && _errorMessage == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 拍照按钮
                  FloatingActionButton(
                    onPressed: _captureAndProcess,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.circle, size: 56, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  // 上传图片按钮
                  FloatingActionButton(
                    onPressed: _pickAndProcessImage,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.photo_library),
                  ),
                ],
              ),
            )
          : null, // 相机未就绪或正在处理时不显示按钮
    );
  }

  // 构建相机预览 Widget
  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      // 如果有错误信息（权限或初始化失败），显示错误文本
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (!_isCameraInitialized || _cameraController == null) {
      // 如果正在初始化，显示加载指示器
      return const Center(child: CircularProgressIndicator());
    }
    // 相机准备就绪，显示预览
    return ClipRRect( // 添加圆角
      borderRadius: BorderRadius.circular(16.0),
      child: CameraPreview(_cameraController!),
    );
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
}

