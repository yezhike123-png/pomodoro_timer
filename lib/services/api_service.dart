import 'dart:convert';
import 'package:http/http.dart' as http;

/// API 服务 —— 与后端通信，读写数据
/// 替代原来的 SharedPreferences 本地存储
class ApiService {
  // 后端地址
  // Web 端用 localhost，移动端/桌面端也用 localhost（后端在本机运行）
  static const String baseUrl = 'http://localhost:8001';

  // ==================== 设置相关 ====================

  /// 读取用户设置
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/settings'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // 后端未启动时返回默认值
    }
    // 返回默认设置
    return {
      'focusMinutes': 25,
      'shortBreakMinutes': 5,
      'longBreakMinutes': 15,
      'longBreakInterval': 4,
      'soundEnabled': true,
      'notificationEnabled': true,
    };
  }

  /// 更新单个设置项
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/api/settings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({_toSnakeCase(key): value}),
      );
    } catch (e) {
      // 后端不可用时静默失败
    }
  }

  // ==================== 记录相关 ====================

  /// 获取番茄完成记录
  Future<List<Map<String, dynamic>>> getSessions({int days = 365}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions?days=$days'),
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // 后端未启动时返回空列表
    }
    return [];
  }

  /// 添加一条番茄完成记录
  Future<void> addSession({
    required int durationMinutes,
    String? date,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'durationMinutes': durationMinutes,
          if (date != null) 'date': date,
        }),
      );
    } catch (e) {
      // 后端不可用时静默失败
    }
  }

  // ==================== 工具方法 ====================

  /// camelCase → snake_case（Flutter 用驼峰，后端用下划线）
  String _toSnakeCase(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
