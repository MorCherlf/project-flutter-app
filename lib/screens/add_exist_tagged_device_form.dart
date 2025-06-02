import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddExistTaggedDeviceForm extends StatelessWidget {
  final String? qrCodeData;
  final String? recognizedText;

  const AddExistTaggedDeviceForm({
    super.key,
    this.qrCodeData,
    this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exist Tagged Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // 使用 ListView 避免内容过多溢出
          children: [
            Text('QR Code:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(qrCodeData ?? 'Can\'t read QR Code'), // 显示 QR 数据，如果为 null 则显示提示
            const Divider(height: 32),
            Text('Text Tag Content:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(recognizedText != null && recognizedText!.isNotEmpty
                ? recognizedText!
                : 'Can\'t Recognize Text Tag'), // 显示文本，如果为空则显示提示
            const SizedBox(height: 32),
            // TODO: 在这里添加你的表单字段，可以使用这些识别到的数据作为初始值
            TextFormField(
              initialValue: qrCodeData,
              decoration: const InputDecoration(labelText: 'Qr Code Content'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: recognizedText,
              decoration: const InputDecoration(labelText: 'Tag Content'),
              maxLines: 3, // 允许多行显示识别的文本
            ),
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {
                  // TODO: 实现表单提交逻辑
                  print('提交表单...');
                  Navigator.of(context).pop(); // 示例：提交后返回
                },
                child: const Text('Submit'))
          ],
        ),
      ),
    );
  }
}