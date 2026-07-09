from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .config import DATABASE_URL
from .models import Base

# SQLite 需要额外参数，其他数据库不需要
connect_args = {}
if "sqlite" in DATABASE_URL:
    connect_args = {"check_same_thread": False}

# 创建数据库引擎
engine = create_engine(DATABASE_URL, connect_args=connect_args, pool_pre_ping=True)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def init_db():
    """创建所有表（App 启动时调用，幂等操作）"""
    Base.metadata.create_all(bind=engine)


def get_db():
    """获取数据库会话（FastAPI 依赖注入用）"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
