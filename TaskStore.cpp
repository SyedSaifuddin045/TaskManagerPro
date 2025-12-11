#include "TaskStore.h"
#include "Task.h"
#include <QFile>
#include <QDataStream>
#include <QDebug>

static constexpr quint32 MAGIC = 0x54534B46; // "TSKF"
static constexpr quint16 VERSION = 1;

TaskStore::TaskStore(QObject *parent) : QObject(parent) {}

bool TaskStore::save(const QVector<Task*> &tasks, const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "TaskStore: Cannot open file for writing:" << filePath;
        return false;
    }

    QDataStream out(&file);
    out.setVersion(QDataStream::Qt_6_5);

    out << MAGIC << VERSION << quint32(tasks.size());

    for (Task *t : tasks) {
        if (!writeTask(out, t)) {
            qWarning() << "TaskStore: Failed to write task";
            return false;
        }
    }

    return true;
}

// NEW IMPLEMENTATION: returns bool, fills outTasks
bool TaskStore::load(const QString &filePath, QVector<Task*> &outTasks, QObject *taskParent)
{
    outTasks.clear(); // Always start clean

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        // No file = not an error (first run)
        return true;
    }

    QDataStream in(&file);
    in.setVersion(QDataStream::Qt_6_5);

    quint32 magic, count;
    quint16 version;

    in >> magic;
    if (magic != MAGIC) {
        qWarning() << "TaskStore: Invalid file format (wrong magic)";
        return false;
    }

    in >> version;
    if (version != VERSION) {
        qWarning() << "TaskStore: Unsupported file version:" << version;
        return false;
    }

    in >> count;
    outTasks.reserve(count);

    for (quint32 i = 0; i < count; ++i) {
        Task *t = readTask(in, taskParent);
        if (!t) {
            qWarning() << "TaskStore: Failed to read task" << i;
            // Clean up already loaded tasks on error
            qDeleteAll(outTasks);
            outTasks.clear();
            return false;
        }
        outTasks.append(t);
    }

    qDebug() << "TaskStore: Successfully loaded" << outTasks.size() << "tasks";
    return true;
}

bool TaskStore::writeTask(QDataStream &out, const Task *task)
{
    out << task->toByteArray();
    return (out.status() == QDataStream::Ok);
}

Task* TaskStore::readTask(QDataStream &in, QObject *taskParent)
{
    QByteArray bytes;
    in >> bytes;
    if (bytes.isEmpty() || in.status() != QDataStream::Ok)
        return nullptr;

    return Task::fromByteArray(bytes, taskParent);
}
