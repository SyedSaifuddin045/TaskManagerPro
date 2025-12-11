#ifndef TASKSTORE_H
#define TASKSTORE_H

#include <QObject>
#include <QVector>
#include <QString>

class Task;

class TaskStore : public QObject
{
    Q_OBJECT
public:
    explicit TaskStore(QObject *parent = nullptr);

    bool save(const QVector<Task*> &tasks, const QString &filePath);

    bool load(const QString &filePath, QVector<Task*> &outTasks, QObject *taskParent = nullptr);

private:
    bool writeTask(QDataStream &out, const Task *task);
    Task* readTask(QDataStream &in, QObject *taskParent);
};

#endif // TASKSTORE_H
