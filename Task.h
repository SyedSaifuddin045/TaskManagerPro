#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QDateTime>
#include <cstdint>

class Task : public QObject
{
    Q_OBJECT
public:
    explicit Task(uint8_t taskId, const QString &taskName, const QString &taskDescription, QObject *parent = nullptr);

    // Getters
    uint8_t taskId() const;
    QString taskName() const;
    QString taskDescription() const;
    bool isCompleted() const;
    QDateTime createdTime() const;
    QDateTime completedTime() const;

    // Setters
    void setTaskName(const QString &name);
    void setTaskDescription(const QString &description);

    // Action
    void markCompleted();

signals:
    void taskCompleted(Task *task);

private:
    uint8_t m_taskId;
    char m_taskName[33];
    char m_taskDescription[256];
    bool m_completed;
    QDateTime m_createdTime;
    QDateTime m_completedTime;
};

#endif // TASK_H
