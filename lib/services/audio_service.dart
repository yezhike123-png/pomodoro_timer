import 'package:audioplayers/audioplayers.dart';

/// 音频服务 —— 提示音 + 白噪音
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _noisePlayer = AudioPlayer();
  bool _isNoisePlaying = false;

  bool get isNoisePlaying => _isNoisePlaying;

  /// 播放计时结束提示音
  /// [soundType]: bell / chime / piano
  Future<void> playTimerEndSound({String soundType = 'bell'}) async {
    try {
      final path = _soundPath(soundType);
      await _player.play(AssetSource(path));
    } catch (_) {}
  }

  /// 开始播放白噪音（循环）
  /// [noiseType]: rain / forest / cafe
  Future<void> startWhiteNoise(String noiseType) async {
    if (_isNoisePlaying) await stopWhiteNoise();
    try {
      await _noisePlayer.setReleaseMode(ReleaseMode.loop);
      await _noisePlayer.play(AssetSource(_noisePath(noiseType)));
      _isNoisePlaying = true;
    } catch (_) {}
  }

  /// 停止白噪音
  Future<void> stopWhiteNoise() async {
    try {
      await _noisePlayer.stop();
    } catch (_) {}
    _isNoisePlaying = false;
  }

  /// 根据类型返回提示音路径
  String _soundPath(String type) {
    switch (type) {
      case 'bell':  return 'sounds/bell.wav';
      case 'chime': return 'sounds/chime.wav';
      case 'piano': return 'sounds/piano.wav';
      default:      return 'sounds/bell.wav';
    }
  }

  /// 根据类型返回白噪音路径
  String _noisePath(String type) {
    switch (type) {
      case 'rain':   return 'sounds/rain.wav';
      case 'forest': return 'sounds/forest.wav';
      case 'cafe':   return 'sounds/cafe.wav';
      default:       return 'sounds/rain.wav';
    }
  }

  void dispose() {
    _player.dispose();
    _noisePlayer.dispose();
  }
}
