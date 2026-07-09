import os

# 数据库连接：优先用环境变量（MySQL），没设就用 SQLite（开箱即用）
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///" + os.path.join(os.path.dirname(__file__), "..", "pomodoro.db"),
)
