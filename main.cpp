#include <QCoreApplication>
#include <QtCore> // QTimer
#include <QDebug>

#include "task.h"
#include "processfilestask.h"

int main(int argc, char *argv[])
{

    qDebug("main:QCoreApplication a(argc, argv)");
    QCoreApplication a(argc, argv);

    qDebug("main:ProcessFilesTask *processFilesTask = new ProcessFilesTask(&a)");

    // This is stupid. I don't want to pass in details about the file task in the constructor.  How to set data parameters?

    ProcessFilesTask *processFilesTask = new ProcessFilesTask(&a);


    qDebug("main:QObject::connect(processFilesTask, SIGNAL(finished()), &a, SLOT(quit()))");
    QObject::connect(processFilesTask, SIGNAL(finished()), &a, SLOT(quit())); // or SLOT(close()?
    // This will run the task from the application event loop.

    qDebug("main:QTimer::singleShot(0, processFilesTask, SLOT(run()))");
    QTimer::singleShot(0, processFilesTask, SLOT(run()));

    // exit(non-zero)?

    qDebug("main:int returnvalue = a.exec()");
    int returnvalue = a.exec();
    qDebug("main:returned value = %d", returnvalue);
    return returnvalue;
}
