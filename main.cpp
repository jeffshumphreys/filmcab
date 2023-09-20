#include <QCoreApplication>
#include <QtCore> // QTimer
#include <QDebug>

#include "task.h"
#include "showfilestask.h"

int main(int argc, char *argv[])
{

    qDebug("main:QCoreApplication a(argc, argv)");
    QCoreApplication a(argc, argv);

    qDebug("main:ShowFilesTask *showFilesTask = new ShowFilesTask(&a)");
    ShowFilesTask *showFilesTask = new ShowFilesTask(&a);

    qDebug("main:QObject::connect(showFilesTask, SIGNAL(finished()), &a, SLOT(quit()))");
    QObject::connect(showFilesTask, SIGNAL(finished()), &a, SLOT(quit())); // or SLOT(close()?
    // This will run the task from the application event loop.

    qDebug("main:QTimer::singleShot(0, showFilesTask, SLOT(run()))");
    QTimer::singleShot(0, showFilesTask, SLOT(run()));

    // exit(non-zero)?

    qDebug("main:int returnvalue = a.exec()");
    int returnvalue = a.exec();
    qDebug("main:returned value = %d", returnvalue);
    return returnvalue;
}
