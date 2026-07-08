from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Setting

router = APIRouter(prefix="/api/settings", tags=["settings"])


def _get_settings(db: Session) -> Setting:
    """获取设置（单行），不存在则创建"""
    settings = db.query(Setting).first()
    if settings is None:
        settings = Setting(id=1)
        db.add(settings)
        db.commit()
        db.refresh(settings)
    return settings


@router.get("")
def get_settings(db: Session = Depends(get_db)):
    """读取当前设置"""
    s = _get_settings(db)
    return {
        "focusMinutes": s.focus_minutes,
        "shortBreakMinutes": s.short_break_minutes,
        "longBreakMinutes": s.long_break_minutes,
        "longBreakInterval": s.long_break_interval,
        "soundEnabled": s.sound_enabled,
        "notificationEnabled": s.notification_enabled,
    }


@router.put("")
def update_settings(
    focusMinutes: int = None,
    shortBreakMinutes: int = None,
    longBreakMinutes: int = None,
    longBreakInterval: int = None,
    soundEnabled: bool = None,
    notificationEnabled: bool = None,
    db: Session = Depends(get_db),
):
    """更新设置（只传需要改的字段）"""
    s = _get_settings(db)
    if focusMinutes is not None:
        s.focus_minutes = focusMinutes
    if shortBreakMinutes is not None:
        s.short_break_minutes = shortBreakMinutes
    if longBreakMinutes is not None:
        s.long_break_minutes = longBreakMinutes
    if longBreakInterval is not None:
        s.long_break_interval = longBreakInterval
    if soundEnabled is not None:
        s.sound_enabled = soundEnabled
    if notificationEnabled is not None:
        s.notification_enabled = notificationEnabled
    db.commit()
    return {"message": "设置已更新"}
