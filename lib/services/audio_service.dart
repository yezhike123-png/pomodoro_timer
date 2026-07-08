import 'package:audioplayers/audioplayers.dart';

/// 音频服务 —— 播放计时结束提示音
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// 播放计时结束提示音
  /// 如果找不到音频文件，静默失败（不影响核心功能）
  Future<void> playTimerEndSound() async {
    try {
      await _player.play(
        AssetSource('sounds/timer_end.wav'),
      );
    } catch (e) {
      // 音频文件不存在或播放失败时静默处理
      // 通知仍然会弹出，不影响用户体验
    }
  }

  /// 释放播放器资源
  void dispose() {
    _player.dispose();
  }
}
