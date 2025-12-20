#include "TaskListModel.h"
#include <QDebug>
#include <algorithm>

TaskListModel::TaskListModel(TaskManager *manager, QObject *parent)
    : QAbstractListModel(parent)
    , m_manager(manager)
{
    // Connect to manager signals
    connect(m_manager, &TaskManager::taskAdded, this, &TaskListModel::onTaskAdded);
    connect(m_manager, &TaskManager::taskRemoved, this, &TaskListModel::onTaskRemoved);
    connect(m_manager, &TaskManager::taskChanged, this, &TaskListModel::onTaskChanged);
    connect(m_manager, &TaskManager::tasksReset, this, &TaskListModel::onTasksReset);
}

int TaskListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_manager->tasks().size();
}

QVariant TaskListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_manager->tasks().size())
        return QVariant();

    const Task *task = m_manager->tasks().at(index.row());

    switch (role) {
    case TaskIdRole:
        return task->taskId();
    case TaskNameRole:
        return task->taskName();
    case TaskDescriptionRole:
        return task->taskDescription();
    case TaskStatusRole:
        return static_cast<int>(task->status());
    case TaskPriorityRole:
        return static_cast<int>(task->priority());
    case TaskIsCompletedRole:
        return task->isCompleted();
    case TaskCreatedTimeRole:
        return task->createdTime().toString("yyyy-MM-dd hh:mm");
    case TaskCompletedTimeRole:
        return task->isCompleted() ? task->completedTime().toString("yyyy-MM-dd hh:mm") : QString();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TaskListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TaskIdRole] = "taskId";
    roles[TaskNameRole] = "taskName";
    roles[TaskDescriptionRole] = "taskDescription";
    roles[TaskStatusRole] = "taskStatus";
    roles[TaskPriorityRole] = "taskPriority";
    roles[TaskIsCompletedRole] = "isCompleted";
    roles[TaskCreatedTimeRole] = "createdTime";
    roles[TaskCompletedTimeRole] = "completedTime";
    return roles;
}

void TaskListModel::addTask(const QString &name, const QString &description, int priority)
{
    TaskPriority prio = static_cast<TaskPriority>(priority);
    m_manager->addTask(name, description, prio);
}

void TaskListModel::removeTask(int taskId)
{
    qDebug() << "TaskListModel: Removing task with ID:" << taskId;

    // Find the row before removal
    int row = findRowByTaskId(static_cast<uint8_t>(taskId));
    if (row >= 0) {
        qDebug() << "TaskListModel: Found task at row:" << row;

        // Notify model that we're about to remove a row
        beginRemoveRows(QModelIndex(), row, row);

        // Actually remove the task
        bool success = m_manager->removeTask(static_cast<uint8_t>(taskId));

        // End the removal notification
        endRemoveRows();

        if (success) {
            emit countChanged();
            qDebug() << "TaskListModel: Task removed successfully. New count:" << m_manager->tasks().size();
        } else {
            qDebug() << "TaskListModel: Failed to remove task";
        }
    } else {
        qDebug() << "TaskListModel: Task not found with ID:" << taskId;
    }
}

void TaskListModel::completeTask(int taskId)
{
    qDebug() << "TaskListModel: Completing task with ID:" << taskId;
    if (m_manager->completeTask(static_cast<uint8_t>(taskId))) {
        int row = findRowByTaskId(static_cast<uint8_t>(taskId));
        if (row >= 0) {
            QModelIndex idx = index(row);
            emit dataChanged(idx, idx);
            qDebug() << "TaskListModel: Task completed, UI updated";
        }
    }
}

void TaskListModel::startTask(int taskId)
{
    qDebug() << "TaskListModel: Starting task with ID:" << taskId;
    if (m_manager->doTask(static_cast<uint8_t>(taskId))) {
        int row = findRowByTaskId(static_cast<uint8_t>(taskId));
        if (row >= 0) {
            QModelIndex idx = index(row);
            emit dataChanged(idx, idx);
            qDebug() << "TaskListModel: Task started, UI updated";
        }
    }
}

void TaskListModel::resetTask(int taskId)
{
    qDebug() << "TaskListModel: Resetting task with ID:" << taskId;

    if (m_manager->resetTask(static_cast<uint8_t>(taskId))) {
        // Find the row of the task to emit dataChanged
        int row = findRowByTaskId(static_cast<uint8_t>(taskId));
        if (row >= 0) {
            QModelIndex idx = index(row);
            emit dataChanged(idx, idx, {TaskStatusRole, TaskCompletedTimeRole, TaskIsCompletedRole});
            qDebug() << "TaskListModel: Task reset to Pending, UI updated";
        }
    } else {
        qDebug() << "TaskListModel: Failed to reset task with ID:" << taskId;
    }
}
void TaskListModel::saveToFile()
{
    m_manager->save();
}

void TaskListModel::loadFromFile()
{
    qDebug() << "TaskListModel: Loading from file...";
    bool success = m_manager->load();
    qDebug() << "TaskListModel: Load" << (success ? "successful" : "failed");
    qDebug() << "TaskListModel: Task count after load:" << m_manager->tasks().size();
}

QString TaskListModel::priorityToString(int priority) const
{
    switch (static_cast<TaskPriority>(priority)) {
    case LOW: return "Low";
    case MEDIUM: return "Medium";
    case HIGH: return "High";
    default: return "Unknown";
    }
}

QString TaskListModel::statusToString(int status) const
{
    switch (static_cast<TaskStatus>(status)) {
    case PENDING: return "Pending";
    case IN_PROGRESS: return "In Progress";
    case COMPLETED: return "Completed";
    default: return "Unknown";
    }
}

void TaskListModel::onTaskAdded(Task *task)
{
    Q_UNUSED(task)
    int row = m_manager->tasks().size() - 1;
    beginInsertRows(QModelIndex(), row, row);
    endInsertRows();
    emit countChanged();
}

void TaskListModel::onTaskRemoved(uint8_t taskId)
{
    // This signal is emitted AFTER the task is already removed from the manager
    // So we don't need to call beginRemoveRows/endRemoveRows here
    // The removal is already handled in removeTask() method
    qDebug() << "TaskListModel::onTaskRemoved signal received for task ID:" << taskId;
}

void TaskListModel::onTaskChanged(Task *task)
{
    int row = findRowByTaskId(task->taskId());
    if (row >= 0) {
        QModelIndex idx = index(row);
        emit dataChanged(idx, idx);
    }
}

void TaskListModel::onTasksReset()
{
    beginResetModel();
    endResetModel();
    emit countChanged();
}

int TaskListModel::findRowByTaskId(uint8_t taskId) const
{
    const QVector<Task*> &tasks = m_manager->tasks();
    for (int i = 0; i < tasks.size(); ++i) {
        if (tasks[i]->taskId() == taskId)
            return i;
    }
    return -1;
}

void TaskListModel::sortByPriority(bool ascending)
{
    qDebug() << "TaskListModel: Sorting by priority, ascending:" << ascending;

    beginResetModel();

    QVector<Task*> &tasks = const_cast<QVector<Task*>&>(m_manager->tasks());

    // Sort tasks by priority
    std::sort(tasks.begin(), tasks.end(), [ascending](Task* a, Task* b) {
        if (ascending) {
            return a->priority() < b->priority();  // LOW -> MEDIUM -> HIGH
        } else {
            return a->priority() > b->priority();  // HIGH -> MEDIUM -> LOW
        }
    });

    endResetModel();

    qDebug() << "TaskListModel: Sorting complete";
}
