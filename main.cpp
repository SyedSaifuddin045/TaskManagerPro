#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include "TaskManager.h"
#include "TaskListModel.h"
#include "Task.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("MyCompany");
    app.setApplicationName("TaskManager");

    // Determine save file path
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataPath);
    QString filePath = dataPath + "/tasks.dat";

    // Create manager and model
    TaskManager *manager = new TaskManager(filePath, &app);
    TaskListModel *model = new TaskListModel(manager, &app);

    // Try to load existing tasks
    manager->load();

    QQmlApplicationEngine engine;

    // Expose model to QML
    engine.rootContext()->setContextProperty("taskModel", model);

    const QUrl url(QStringLiteral("qrc:/MyApp/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "QML failed to load:" << url;
        return -1;
    }

    return app.exec();
}
