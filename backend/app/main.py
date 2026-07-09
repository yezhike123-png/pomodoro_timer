from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import init_db
from .routers import settings, sessions, tasks

app = FastAPI(title="番茄计时器 API", version="1.0.0")

# CORS 跨域：允许 Web 前端（任何端口）访问后端
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(settings.router)
app.include_router(sessions.router)
app.include_router(tasks.router)


@app.on_event("startup")
def on_startup():
    """App 启动时自动创建数据库表（SQLite 首次运行自动生成 .db 文件）"""
    init_db()


@app.get("/")
def root():
    return {"message": "🍅 番茄计时器 API 运行中"}
