/// 计时器状态枚举
enum TimerState {
  idle,     // 空闲，未开始
  running,  // 计时中
  paused,   // 已暂停
  finished, // 已完成（等待用户确认进入下一阶段）
}
