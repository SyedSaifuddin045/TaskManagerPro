#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QDateTime>
#include <QByteArray>
#include <cstdint>

enum TaskStatus : uint8_t {
    PENDING,
    IN_PROGRESS,
    COMPLETED
};

enum TaskPriority : uint8_t {
    LOW,
    MEDIUM,
    HIGH
};

class Task : public QObject
{
    Q_OBJECT
public:
    explicit Task(uint8_t taskId,
                  const QString &taskName,
                  const QString &taskDescription,
                  const TaskPriority &taskPriority,
                  QObject *parent = nullptr);

    // Getters
    uint8_t taskId() const;
    QString taskName() const;
    QString taskDescription() const;
    TaskStatus status() const;
    TaskPriority priority() const;
    bool isCompleted() const;
    QDateTime createdTime() const;
    QDateTime completedTime() const;

    // Setters
    void setTaskName(const QString &name);
    void setTaskDescription(const QString &description);
    void setStatus(TaskStatus status);
    void setPriority(TaskPriority p);

    // Actions
    void markCompleted();

    // Serialization
    QByteArray toByteArray() const;
    static Task* fromByteArray(const QByteArray &data, QObject *parent = nullptr);

signals:
    void taskCompleted(Task *task);

private:
    uint8_t m_taskId;
    char m_taskName[33];
    char m_taskDescription[256];

    TaskStatus m_taskStatus;
    TaskPriority m_priority;

    QDateTime m_createdTime;
    QDateTime m_completedTime;
};

#endif // TASK_H
