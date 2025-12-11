#include "Task.h"
#include <QDataStream>
#include <cstring>
#include <QIODevice>

Task::Task(uint8_t taskId,
           const QString &taskName,
           const QString &taskDescription,
           const TaskPriority &taskPriority,
           QObject *parent)
    : QObject(parent),
    m_taskId(taskId),
    m_taskStatus(TaskStatus::PENDING),
    m_priority(taskPriority),
    m_createdTime(QDateTime::currentDateTimeUtc()),
    m_completedTime({})
{
    setTaskName(taskName);
    setTaskDescription(taskDescription);
}

// -------------------- Getters --------------------
uint8_t Task::taskId() const { return m_taskId; }
QString Task::taskName() const { return QString::fromUtf8(m_taskName); }
QString Task::taskDescription() const { return QString::fromUtf8(m_taskDescription); }
TaskStatus Task::status() const { return m_taskStatus; }
TaskPriority Task::priority() const { return m_priority; }
bool Task::isCompleted() const { return m_taskStatus == COMPLETED; }
QDateTime Task::createdTime() const { return m_createdTime; }
QDateTime Task::completedTime() const { return m_completedTime; }

// -------------------- Setters --------------------
void Task::setTaskName(const QString &name)
{
    QByteArray bytes = name.left(32).toUtf8();
    std::strncpy(m_taskName, bytes.constData(), sizeof(m_taskName) - 1);
    m_taskName[sizeof(m_taskName)-1] = '\0';
}

void Task::setTaskDescription(const QString &description)
{
    QByteArray bytes = description.left(255).toUtf8();
    std::strncpy(m_taskDescription, bytes.constData(), sizeof(m_taskDescription) - 1);
    m_taskDescription[sizeof(m_taskDescription)-1] = '\0';
}

void Task::setStatus(TaskStatus status)
{
    m_taskStatus = status;
    if (status == COMPLETED)
        m_completedTime = QDateTime::currentDateTimeUtc();
}

void Task::setPriority(TaskPriority p)
{
    m_priority = p;
}

// -------------------- Actions --------------------
void Task::markCompleted()
{
    if (m_taskStatus != COMPLETED) {
        m_taskStatus = COMPLETED;
        m_completedTime = QDateTime::currentDateTimeUtc();
        emit taskCompleted(this);
    }
}

// -------------------- Serialization --------------------
QByteArray Task::toByteArray() const
{
    QByteArray arr;
    QDataStream out(&arr, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_6_5);

    out << m_taskId;
    out.writeRawData(m_taskName, sizeof(m_taskName));
    out.writeRawData(m_taskDescription, sizeof(m_taskDescription));
    out << static_cast<uint8_t>(m_taskStatus);
    out << static_cast<uint8_t>(m_priority);
    out << m_createdTime;
    out << m_completedTime;

    return arr;
}

Task* Task::fromByteArray(const QByteArray &data, QObject *parent)
{
    QDataStream in(data);
    in.setVersion(QDataStream::Qt_6_5);

    uint8_t id;
    char name[33];
    char desc[256];
    uint8_t status;
    uint8_t priority;
    QDateTime created;
    QDateTime completed;

    in >> id;
    in.readRawData(name, sizeof(name));
    in.readRawData(desc, sizeof(desc));
    in >> status;
    in >> priority;
    in >> created;
    in >> completed;

    TaskPriority pr = static_cast<TaskPriority>(priority);

    Task *task = new Task(id, QString::fromUtf8(name), QString::fromUtf8(desc), pr, parent);
    task->m_taskStatus = static_cast<TaskStatus>(status);
    task->m_priority   = static_cast<TaskPriority>(priority);
    task->m_createdTime = created;
    task->m_completedTime = completed;

    return task;
}
