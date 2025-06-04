import 'package:flutter/material.dart';
import 'package:project/services/data_service.dart';
import 'package:project/utils/haptics.dart';
import 'package:provider/provider.dart';

class AddNewDeviceForm extends StatefulWidget {
  final String? qrCodeData;

  const AddNewDeviceForm({
    super.key,
    this.qrCodeData,
  });

  @override
  State<AddNewDeviceForm> createState() => _AddNewDeviceFormState();
}

class _AddNewDeviceFormState extends State<AddNewDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    AppHaptics.mediumImpact();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        
        // 准备提交的数据
        final itemData = {
          'name': _nameController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'itemId': widget.qrCodeData, // 使用扫描到的二维码数据作为设备ID
        };

        // 调用API添加设备
        final result = await dataService.addItem(itemData);
        
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device added successfully')),
          );
          Navigator.of(context).pop(true); // 返回true表示添加成功
        } else {
          throw Exception('Device add failed');
        }
      } catch (e) {
        print('Submit error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submit failed, please try again')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Device'),
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
