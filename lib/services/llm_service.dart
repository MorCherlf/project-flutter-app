import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LLMService {
  static String get _apiEndpoint => ApiConfig.apiEndpoint;
  static String get _apiToken => ApiConfig.apiToken;

  static Future<String> getCompletion(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiToken',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a smart assistant, you need to help user to fill the device infomation. Please give your best advice base on the context.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.6,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('API请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('LLM API错误: $e');
      return '';
    }
  }
} 