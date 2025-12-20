#ifndef TASKLISTMODEL_H
#define TASKLISTMODEL_H

#include <QAbstractListModel>
#include "TaskManager.h"

class TaskListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum TaskRoles {
        TaskIdRole = Qt::UserRole + 1,
        TaskNameRole,
        TaskDescriptionRole,
        TaskStatusRole,
        TaskPriorityRole,
        TaskIsCompletedRole,
        TaskCreatedTimeRole,
        TaskCompletedTimeRole
    };

    explicit TaskListModel(TaskManager *manager, QObject *parent = nullptr);

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Invokable methods for QML
    Q_INVOKABLE void addTask(const QString &name, const QString &description, int priority);
    Q_INVOKABLE void removeTask(int taskId);
    Q_INVOKABLE void completeTask(int taskId);
    Q_INVOKABLE void startTask(int taskId);
    Q_INVOKABLE void resetTask(int taskId);
    Q_INVOKABLE void saveToFile();
    Q_INVOKABLE void loadFromFile();
    Q_INVOKABLE QString priorityToString(int priority) const;
    Q_INVOKABLE QString statusToString(int status) const;
    Q_INVOKABLE void sortByPriority(bool ascending = false);

signals:
    void countChanged();

private slots:
    void onTaskAdded(Task *task);
    void onTaskRemoved(uint8_t taskId);
    void onTaskChanged(Task *task);
    void onTasksReset();

private:
    TaskManager *m_manager;
    int findRowByTaskId(uint8_t taskId) const;
};

#endif // TASKLISTMODEL_H
