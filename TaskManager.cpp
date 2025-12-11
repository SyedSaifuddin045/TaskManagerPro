#include "TaskManager.h"
#include <QFile>
#include <QDebug>

TaskManager::TaskManager(const QString &filePath, QObject *parent)
    : QObject(parent)
    , m_store(new TaskStore(this))
    , m_filePath(filePath)
{
    // Optional: auto-load on construction
    // load();
}

Task* TaskManager::addTask(const QString &name, const QString &desc, TaskPriority prio)
{
    // Determine next ID: start from 1, increment from highest
    uint8_t newId = 1;
    if (!m_tasks.isEmpty()) {
        for (const Task* t : m_tasks) {  // read-only, const pointer
            if (t->taskId() >= newId)
                newId = t->taskId() + 1;
        }
    }

    Task *task = new Task(newId, name, desc, prio, this);
    m_tasks.append(task);

    // Forward completion signal
    connect(task, &Task::taskCompleted, this, &TaskManager::onTaskCompleted);

    emit taskAdded(task);
    qDebug() << "Task added:" << task->taskName() << "(ID:" << newId << ")";

    return task;
}

bool TaskManager::removeTask(uint8_t id)
{
    int index = indexOfTask(id);
    if (index == -1) {
        qWarning() << "removeTask: Task with ID" << id << "not found";
        return false;
    }

    Task *task = m_tasks.takeAt(index);
    emit taskRemoved(id);
    task->deleteLater();

    qDebug() << "Task removed: ID" << id;
    return true;
}

Task* TaskManager::getTaskById(uint8_t id) const
{
    for (Task* const task : m_tasks) {  // Task* const avoids detach
        if (task->taskId() == id)
            return task;
    }
    return nullptr;
}

int TaskManager::indexOfTask(uint8_t id) const
{
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_tasks[i]->taskId() == id)
            return i;
    }
    return -1;
}

void TaskManager::onTaskCompleted(Task *task)
{
    // Forward any completion (or other changes) as a general taskChanged signal
    emit taskChanged(task);
}

bool TaskManager::completeTask(uint8_t id)
{
    for (Task* const it : m_tasks) {  // Task* const
        if (it->taskId() == id) {
            it->markCompleted();
            return true;
        }
    }
    return false;
}

bool TaskManager::doTask(uint8_t id)
{
    for (Task* const it : m_tasks) {  // Task* const
        if (it->taskId() == id) {
            it->setStatus(IN_PROGRESS);
            return true;
        }
    }
    return false;
}

bool TaskManager::load()
{
    QVector<Task*> loaded;
    if (!m_store->load(m_filePath, loaded, this)) {  // Pass parent for ownership
        qWarning() << "Failed to load tasks from" << m_filePath;
        return false;
    }

    // Clean up old tasks
    for (Task* const t : m_tasks) {  // Task* const avoids detach
        t->disconnect(this);  // Avoid double signals
        t->deleteLater();
    }
    m_tasks.clear();

    m_tasks = loaded;

    // Reconnect completion signals
    for (Task* const task : m_tasks) {  // Task* const
        connect(task, &Task::taskCompleted, this, &TaskManager::onTaskCompleted);
    }

    emit tasksReset();  // Important for QML/ListView to fully refresh
    qDebug() << "Loaded" << m_tasks.size() << "tasks from" << m_filePath;
    return true;
}

bool TaskManager::save()
{
    bool success = m_store->save(m_tasks, m_filePath);
    if (success) {
        qDebug() << "Successfully saved" << m_tasks.size() << "tasks to" << m_filePath;
    } else {
        qWarning() << "Failed to save tasks to" << m_filePath;
    }
    return success;
}
