#include "Task.h"
#include <cstring>

Task::Task(uint8_t taskId, const QString &taskName, const QString &taskDescription, QObject *parent)
    : QObject(parent),
    m_taskId(taskId),
    m_completed(false),
    m_createdTime(QDateTime::currentDateTime()),
    m_completedTime({})
{
    setTaskName(taskName);
    setTaskDescription(taskDescription);
}

// Getters
uint8_t Task::taskId() const { return m_taskId; }

QString Task::taskName() const { return QString::fromUtf8(m_taskName); }

QString Task::taskDescription() const { return QString::fromUtf8(m_taskDescription); }

bool Task::isCompleted() const { return m_completed; }

QDateTime Task::createdTime() const { return m_createdTime; }

QDateTime Task::completedTime() const { return m_completedTime; }

// Setters
void Task::setTaskName(const QString &name)
{
    QByteArray bytes = name.left(32).toUtf8();
    std::strncpy(m_taskName, bytes.constData(), sizeof(m_taskName) - 1);
    m_taskName[sizeof(m_taskName) - 1] = '\0';
}

void Task::setTaskDescription(const QString &description)
{
    QByteArray bytes = description.left(255).toUtf8();
    std::strncpy(m_taskDescription, bytes.constData(), sizeof(m_taskDescription) - 1);
    m_taskDescription[sizeof(m_taskDescription) - 1] = '\0';
}

// Mark completion
void Task::markCompleted()
{
    if (!m_completed) {
        m_completed = true;
        m_completedTime = QDateTime::currentDateTime();
        emit taskCompleted(this);
    }
}
