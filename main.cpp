#include <QCoreApplication>
#include "Repl.h"
#include "TaskManager.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    // Set a file path for saving/loading tasks (you can change this)
    QString saveFile = QCoreApplication::applicationDirPath() + "/tasks.json";

    // Create the TaskManager (it will own all Task objects)
    TaskManager manager(saveFile);

    // Create and run the REPL
    Repl repl(&manager);
    repl.run();

    return 0;
}
