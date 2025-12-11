#ifndef REPL_H
#define REPL_H

#include <string>
#include "TaskManager.h"

class Repl
{
public:
    explicit Repl(TaskManager *manager);

    void run();

private:
    TaskManager *m_manager;

    void printHelp();
    void handleAdd(const std::string &cmd);
    void handleList();
    void handleDo(const std::string &cmd);
    void handleComplete(const std::string &cmd);
};

#endif // REPL_H
