from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Setting

router = APIRouter(prefix="/api/settings", tags=["settings"])


def _get_settings(db: Session) -> Setting:
    s = db.query(Setting).first()
    if s is None:
        s = Setting(id=1)
        db.add(s)
        db.commit()
        db.refresh(s)
    return s


@router.get("")
def get_settings(db: Session = Depends(get_db)):
    s = _get_settings(db)
    return {
        "focusMinutes": s.focus_minutes,
        "shortBreakMinutes": s.short_break_minutes,
        "longBreakMinutes": s.long_break_minutes,
        "longBreakInterval": s.long_break_interval,
        "soundEnabled": s.sound_enabled,
        "notificationEnabled": s.notification_enabled,
        "autoStartNext": s.auto_start_next,
        "soundType": s.sound_type,
        "whiteNoise": s.white_noise,
    }


@router.put("")
def update_settings(
    focusMinutes: int = None,
    shortBreakMinutes: int = None,
    longBreakMinutes: int = None,
    longBreakInterval: int = None,
    soundEnabled: bool = None,
    notificationEnabled: bool = None,
    autoStartNext: bool = None,
    soundType: str = None,
    whiteNoise: str = None,
    db: Session = Depends(get_db),
):
    s = _get_settings(db)
    for key, val in {
        "focus_minutes": focusMinutes, "short_break_minutes": shortBreakMinutes,
        "long_break_minutes": longBreakMinutes, "long_break_interval": longBreakInterval,
        "sound_enabled": soundEnabled, "notification_enabled": notificationEnabled,
        "auto_start_next": autoStartNext, "sound_type": soundType, "white_noise": whiteNoise,
    }.items():
        if val is not None:
            setattr(s, key, val)
    db.commit()
    return {"message": "设置已更新"}
