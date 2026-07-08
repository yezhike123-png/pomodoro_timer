from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import settings, sessions

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


@app.get("/")
def root():
    return {"message": "🍅 番茄计时器 API 运行中"}
