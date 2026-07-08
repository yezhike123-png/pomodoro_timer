from sqlalchemy import Column, Integer, String, DateTime, Boolean, func
from sqlalchemy.orm import declarative_base

Base = declarative_base()


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
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())


class Session(Base):
    """番茄完成记录模型"""
    __tablename__ = "sessions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(DateTime, nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    task_title = Column(String(200), nullable=True)
    created_at = Column(DateTime, server_default=func.now())
