from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.orm import declarative_base

Base = declarative_base()


def _now():
    """返回当前 UTC 时间（兼容 SQLite 和 MySQL）"""
    return datetime.now(timezone.utc)


class Setting(Base):
    """用户设置模型"""
    __tablename__ = "settings"

    id = Column(Integer, primary_key=True, default=1)
    focus_minutes = Column(Integer, default=25)
    short_break_minutes = Column(Integer, default=5)
    long_break_minutes = Column(Integer, default=15)
    long_break_interval = Column(Integer, default=4)
    sound_enabled = Column(Boolean, default=True)
    notification_enabled = Column(Boolean, default=True)
    updated_at = Column(DateTime, default=_now, onupdate=_now)


class Session(Base):
    """番茄完成记录模型"""
    __tablename__ = "sessions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(DateTime, nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    task_title = Column(String(200), nullable=True)
    task_id = Column(Integer, nullable=True, comment="关联的任务 ID")
    created_at = Column(DateTime, default=_now)


class Task(Base):
    """待办任务模型"""
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(200), nullable=False)
    completed = Column(Boolean, default=False)
    pomodoro_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=_now)
