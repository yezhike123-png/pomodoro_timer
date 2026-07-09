from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Task

router = APIRouter(prefix="/api/tasks", tags=["tasks"])


@router.get("")
def list_tasks(db: Session = Depends(get_db)):
    """获取所有任务（未完成的在前）"""
    tasks = db.query(Task).order_by(Task.completed.asc(), Task.created_at.desc()).all()
    return [
        {
            "id": t.id,
            "title": t.title,
            "completed": t.completed,
            "pomodoroCount": t.pomodoro_count,
        }
        for t in tasks
    ]


@router.post("")
def create_task(title: str, db: Session = Depends(get_db)):
    """创建新任务"""
    task = Task(title=title.strip())
    db.add(task)
    db.commit()
    db.refresh(task)
    return {"id": task.id, "title": task.title, "completed": False, "pomodoroCount": 0}


@router.put("/{task_id}")
def update_task(
    task_id: int,
    title: str = None,
    completed: bool = None,
    db: Session = Depends(get_db),
):
    """更新任务"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        return {"error": "任务不存在"}
    if title is not None:
        task.title = title.strip()
    if completed is not None:
        task.completed = completed
    db.commit()
    return {"message": "已更新"}


@router.delete("/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    """删除任务"""
    db.query(Task).filter(Task.id == task_id).delete()
    db.commit()
    return {"message": "已删除"}


@router.post("/{task_id}/pomodoro")
def increment_pomodoro(task_id: int, db: Session = Depends(get_db)):
    """任务番茄数 +1"""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        return {"error": "任务不存在"}
    task.pomodoro_count += 1
    db.commit()
    return {"pomodoroCount": task.pomodoro_count}
