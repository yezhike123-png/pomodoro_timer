from datetime import datetime
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Session as PomodoroSession

router = APIRouter(prefix="/api/sessions", tags=["sessions"])


@router.get("")
def list_sessions(
    days: int = 365,
    db: Session = Depends(get_db),
):
    """获取番茄完成记录（最近 N 天）"""
    since = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    query = db.query(PomodoroSession)
    if days > 0:
        from datetime import timedelta
        cutoff = since - timedelta(days=days)
        query = query.filter(PomodoroSession.date >= cutoff)
    sessions = query.order_by(PomodoroSession.date.desc()).all()
    return [
        {
            "id": s.id,
            "date": s.date.isoformat(),
            "durationMinutes": s.duration_minutes,
            "taskTitle": s.task_title,
        }
        for s in sessions
    ]


@router.post("")
def add_session(
    durationMinutes: int,
    date: str = None,
    db: Session = Depends(get_db),
):
    """添加一条番茄完成记录"""
    session = PomodoroSession(
        date=datetime.fromisoformat(date) if date else datetime.now(),
        duration_minutes=durationMinutes,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return {
        "id": session.id,
        "date": session.date.isoformat(),
        "durationMinutes": session.duration_minutes,
    }
