#include "Repl.h"
#include <iostream>
#include <sstream>

Repl::Repl(TaskManager *manager)
    : m_manager(manager)
{
}

void Repl::printHelp()
{
    std::cout << "===== Commands =====\n";
    std::cout << "help                      Show this menu\n";
    std::cout << "add title|desc|prio       Add a task (priority 0=LOW,1=MEDIUM,2=HIGH)\n";
    std::cout << "list                      Show all tasks\n";
    std::cout << "complete ID               Complete a task\n";
    std::cout << "do ID                     Set a Task to be doing\n";
    std::cout << "save                      Save all tasks\n";
    std::cout << "quit                      Exit\n";
}

void Repl::handleAdd(const std::string &cmd)
{
    // cmd = "add title|desc|prio"
    std::string payload = cmd.substr(4);

    size_t p1 = payload.find('|');
    size_t p2 = payload.find('|', p1 + 1);

    if (p1 == std::string::npos || p2 == std::string::npos)
    {
        std::cout << "Invalid format. Use: add title|desc|prio\n";
        return;
    }

    std::string name = payload.substr(0, p1);
    std::string desc = payload.substr(p1 + 1, p2 - p1 - 1);

    int prio = std::stoi(payload.substr(p2 + 1));

    if (prio < 0 || prio > 2)
    {
        std::cout << "Priority must be 0,1,2\n";
        return;
    }

    TaskPriority priority = static_cast<TaskPriority>(prio);

    Task *t = m_manager->addTask(QString::fromStdString(name),
                                 QString::fromStdString(desc),
                                 priority);

    std::cout << "Added task ID " << int(t->taskId()) << "\n";
}

const char* statusToString(TaskStatus s) {
    switch(s) {
    case PENDING: return "Pending";
    case IN_PROGRESS: return "In Progress";
    case COMPLETED: return "Completed";
    }
    return "Unknown";
}

const char* priorityToString(TaskPriority p) {
    switch(p) {
    case LOW: return "Low";
    case MEDIUM: return "Medium";
    case HIGH: return "High";
    }
    return "Unknown";
}

void Repl::handleList()
{
    auto tasks = m_manager->tasks();

    for (Task *t : tasks)
    {
        std::cout
            << "ID=" << int(t->taskId())
            << " | Name=" << t->taskName().toStdString()
            << " | Description="<<t->taskDescription().toStdString()
            << " | Status=" << statusToString(t->status())
            << " | Priority=" << priorityToString(t->priority())
            << "\n";
    }
}

void Repl::handleComplete(const std::string &cmd)
{
    // cmd = "complete ID"
    int id = std::stoi(cmd.substr(9));

    if (m_manager->completeTask(id))
        std::cout << "Task completed.\n";
    else
        std::cout << "Task not found.\n";
}

void Repl::handleDo(const std::string &cmd)
{
    //cmd = "do ID"
    int id = std::stoi(cmd.substr(3));
    if(m_manager->doTask(id))
        std::cout << "Doing Task : "<<id;
    else
        std::cout << "Task not found.\n";
}

void Repl::run()
{
    // Load saved tasks if possible
    if (!m_manager->load())
        std::cout << "No previous save found.\n";

    printHelp();

    while (true)
    {
        std::cout << "\n> ";

        std::string line;
        std::getline(std::cin, line);

        if (line == "help")
            printHelp();
        else if (line.rfind("add ", 0) == 0)
            handleAdd(line);
        else if (line == "list")
            handleList();
        else if (line.rfind("complete ", 0) == 0)
            handleComplete(line);
        else if (line == "save")
        {
            m_manager->save();
            std::cout << "Tasks saved.\n";
        }
        else if(line.rfind("do ", 0) == 0)
        {
            handleDo(line);
        }
        else if (line == "quit")
        {
            m_manager->save();
            std::cout << "Goodbye.\n";
            break;
        }
        else if (!line.empty())
            std::cout << "Unknown command. Type 'help'.\n";
    }
}
