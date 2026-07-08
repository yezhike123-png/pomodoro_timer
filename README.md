# 🍅 番茄计时器 Pomodoro Timer

全平台番茄工作法 App，一份代码覆盖 **iOS / Android / macOS / Windows / Web** 五个平台。

基于 Flutter 构建，数据通过 FastAPI + MySQL 后端存储，多端共享同一份数据。

---

## ✨ 功能

| 功能 | 说明 |
| ---- | ---- |
| 🍅 专注计时 | 默认 25 分钟，可自定义（5-60 分钟） |
| ☕ 休息计时 | 短休息 5 分钟 / 长休息 15 分钟，每完成 4 个番茄自动长休息 |
| 🔔 计时提醒 | 计时结束播放提示音 + 系统通知 |
| 📊 数据统计 | 今日番茄数、本周番茄数、累计专注时长 |
| ⚙️ 个性化设置 | 所有时长可调，提示音/通知可开关 |
| 🔄 多端数据同步 | Web 和桌面版数据一致，共用同一个 MySQL 数据库 |
| 🔙 后台计时 | 切到后台也能正确计时，回来后进度自动恢复 |

---

## 🛠 技术栈

| 层级 | 技术 |
| ---- | ---- |
| 前端 | Flutter 3.x + Dart + Provider（状态管理） |
| 后端 | FastAPI + SQLAlchemy |
| 数据库 | MySQL |
| 通知 | flutter_local_notifications |
| 音频 | audioplayers |
| 存储 | SharedPreferences（仅通知/音频等本地功能） |

---

## 📂 项目结构

```text
pomodoro_timer/
├── lib/                          # Flutter 主代码
│   ├── main.dart                 # 入口
│   ├── app.dart                  # 主题 + 路由
│   ├── models/                   # 数据模型
│   │   ├── timer_state.dart      # 状态枚举
│   │   ├── timer_mode.dart       # 模式枚举
│   │   └── pomodoro_session.dart # 番茄记录
│   ├── providers/                # 状态管理
│   │   ├── timer_provider.dart   # 核心计时逻辑
│   │   ├── settings_provider.dart # 设置管理
│   │   └── stats_provider.dart   # 统计管理
│   ├── services/                 # 服务层
│   │   ├── api_service.dart      # HTTP API 客户端
│   │   ├── notification_service.dart # 本地通知
│   │   └── audio_service.dart    # 提示音播放
│   ├── screens/                  # 页面
│   │   ├── home_screen.dart      # 主页（计时器）
│   │   ├── settings_screen.dart  # 设置页
│   │   └── stats_screen.dart     # 统计页
│   └── widgets/                  # UI 组件
│       ├── circular_timer.dart   # 圆形进度条
│       ├── control_buttons.dart  # 控制按钮
│       └── session_indicator.dart # 番茄完成指示器
│
├── backend/                      # 后端 API
│   ├── app/
│   │   ├── main.py               # FastAPI 入口
│   │   ├── config.py             # 配置（环境变量）
│   │   ├── database.py           # 数据库连接
│   │   ├── models.py             # SQLAlchemy 模型
│   │   └── routers/              # API 路由
│   │       ├── settings.py       # 设置接口
│   │       └── sessions.py       # 记录接口
│   ├── .env.example              # 环境变量示例
│   └── requirements.txt          # Python 依赖
│
├── assets/sounds/                # 提示音文件
├── ios/                          # iOS 原生代码
├── android/                      # Android 原生代码
└── macos/                        # macOS 原生代码
```

---

## 🚀 快速启动

### 前提条件

- Flutter SDK 3.x ([安装指南](https://docs.flutter.dev/get-started/install))
- MySQL（用于后端数据存储）
- Python 3.10+（用于后端）
- Xcode（仅 macOS/iOS 需要）

### 1. 启动后端

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 创建数据库（在 MySQL 中执行）
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS pomodoro_timer CHARACTER SET utf8mb4;"

# 配置数据库连接
cp .env.example .env
# 编辑 .env，填入你的 MySQL 密码

# 启动后端（端口 8001）
python -m uvicorn app.main:app --reload --port 8001
```

后端启动后，打开 `http://localhost:8001/docs` 查看 API 文档。

### 2. 启动 Flutter App

```bash
# 安装依赖
~/flutter-sdk/bin/flutter pub get

# Web 版（最方便，无需模拟器）
~/flutter-sdk/bin/flutter run -d chrome

# macOS 桌面版
~/flutter-sdk/bin/flutter run -d macos

# iOS 模拟器
~/flutter-sdk/bin/flutter run -d ios

# Android 模拟器
~/flutter-sdk/bin/flutter run -d android
```

> 国内用户可设置 Flutter 镜像加速：
>
> ```bash
> export PUB_HOSTED_URL=https://pub.flutter-io.cn
> export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
> ```

---

## 📦 打包发布

```bash
# macOS（生成 .app 和 .dmg）
~/flutter-sdk/bin/flutter build macos --release

# Web
~/flutter-sdk/bin/flutter build web

# iOS
~/flutter-sdk/bin/flutter build ios --release

# Android
~/flutter-sdk/bin/flutter build apk --release
```

---

## 🔗 数据流

```text
┌──────────┐  HTTP API   ┌──────────────┐  HTTP API   ┌──────────┐
│  Web App │ ◄─────────► │  FastAPI:8001 │ ◄─────────► │ macOS App│
│ (Chrome) │             │     MySQL     │             │  (桌面)   │
└──────────┘             └──────────────┘             └──────────┘
```

所有客户端通过 HTTP API 读写 MySQL，不各自存储数据，保证多端数据完全一致。

---

## 📝 开发笔记

- 计时器后台恢复采用**时间戳差值法**：记录开始时间，回到前台时用 `DateTime.now() - startTime` 计算实际经过时间，避免 iOS 真后台限制
- 首次启动 macOS 需要安装 CocoaPods + 完整 Xcode，并同意 Xcode 许可协议
- 数据库密码等敏感信息通过 `.env` 文件管理，已加入 `.gitignore`，不会提交到 Git

---

## 📄 License

MIT
