import 'package:flutter/material.dart';
import 'package:project/services/llm_service.dart';
import 'package:project/utils/haptics.dart';

class AddExistTaggedDeviceForm extends StatefulWidget {
  final String? qrCodeData;
  final String recognizedText;

  const AddExistTaggedDeviceForm({
    super.key,
    this.qrCodeData,
    required this.recognizedText,
  });

  @override
  State<AddExistTaggedDeviceForm> createState() => _AddExistTaggedDeviceFormState();
}

class _AddExistTaggedDeviceFormState extends State<AddExistTaggedDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _analyzeText();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    if (widget.recognizedText.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 构建提示词
      final prompt = '''
        Please analyze the following text and extract device information. The text is from OCR recognition of a device label.
        Focus on extracting:
        1. Device name/model (look for terms like "Series", "Model", "Product")
        2. Serial number (look for terms like "Serial No.", "S/N")
        3. Product number (look for terms like "Product No.", "P/N")
        4. Any other relevant information that could be used as description

        OCR Recognized Text:
        ${widget.recognizedText}

        Please return in the following format:
        Name: [Device name/model]
        Location: [Default location if found, otherwise leave empty]
        Description: [Combined information including serial number, product number, and other details]
      ''';

      final response = await LLMService.getCompletion(prompt);
      
      if (response.isNotEmpty) {
        // 解析返回的文本
        final lines = response.split('\n');
        for (var line in lines) {
          if (line.startsWith('Name: ')) {
            _nameController.text = line.substring(6).trim();
          } else if (line.startsWith('Location: ')) {
            _locationController.text = line.substring(10).trim();
          } else if (line.startsWith('Description: ')) {
            _descriptionController.text = line.substring(13).trim();
          }
        }
      }
    } catch (e) {
      print('LLM Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LLM analysis failed, please fill in the information manually')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSubmit() {
    AppHaptics.mediumImpact();
    if (_formKey.currentState!.validate()) {
      // TODO: 处理表单提交
      print('表单提交');
      print('名称: ${_nameController.text}');
      print('位置: ${_locationController.text}');
      print('描述: ${_descriptionController.text}');
      print('二维码数据: ${widget.qrCodeData}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exist Tagged Device'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ID 字段（只读）
                    if (widget.qrCodeData != null) ...[
                      const Text(
                        'Device ID',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.qrCodeData!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(Icons.qr_code, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // 名称字段
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 位置字段
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 描述字段
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // 提交按钮
                    ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}