#include <QTextStream>
#include <QString>

int main(int argc, char *argv[])
{
    // QCoreApplication a(argc, argv);

    QTextStream inputStream(stdin);
    QTextStream outputStream(stdout);

    QString name;

    outputStream << "Enter your name : ";
    outputStream.flush();

    name = inputStream.readLine();

    outputStream << "Hello " << name;
    outputStream.flush();

    return 0;
}
