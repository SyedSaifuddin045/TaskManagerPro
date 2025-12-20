#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QObject>
#include <QVector>
#include <QString>
#include "Task.h"
#include "TaskStore.h"

class TaskManager : public QObject
{
    Q_OBJECT

public:
    explicit TaskManager(const QString &filePath, QObject *parent = nullptr);

    // Add a new task
    Task* addTask(const QString &name, const QString &desc, TaskPriority prio = MEDIUM);

    // Remove task by ID
    bool removeTask(uint8_t id);

    bool completeTask(uint8_t id);

    bool doTask(uint8_t id);

    bool resetTask(uint8_t taskId);

    // Get task by ID (for updating or inspection)
    Task* getTaskById(uint8_t id) const;

    // Access all tasks (for models/views)
    const QVector<Task*>& tasks() const { return m_tasks; }

    // Persistence
    bool load();
    bool save();

signals:
    // Emitted when a new task is added
    void taskAdded(Task *task);

    // Emitted when a task is removed
    void taskRemoved(uint8_t taskId);

    // Emitted when a task is modified (name, status, priority, etc.)
    void taskChanged(Task *task);

    // Optional: emitted after full reload (useful for resetting models)
    void tasksReset();

private slots:
    // Connected internally to Task::taskCompleted to forward as taskChanged
    void onTaskCompleted(Task *task);

private:
    QVector<Task*> m_tasks;
    TaskStore *m_store;
    QString m_filePath;

    // Helper: find task index by ID
    int indexOfTask(uint8_t id) const;
};

#endif // TASKMANAGER_H
