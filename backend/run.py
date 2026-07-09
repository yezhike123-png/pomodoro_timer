"""番茄计时器后端入口 —— PyInstaller 打包用"""
import uvicorn
from app.main import app


def main():
    uvicorn.run(app, host="127.0.0.1", port=8001, log_level="info")


if __name__ == "__main__":
    main()
