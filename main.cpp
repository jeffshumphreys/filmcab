#include <QCoreApplication>
#include <QtCore> // QTimer
#include <QDebug>

#include "sharedenumerations.h"
#include "processfilestask.h"

int main(int argc, char *argv[])
{

    qDebug("main:QCoreApplication a(argc, argv)");
    QCoreApplication a(argc, argv);

    QSqlDatabase targetDbForScannedFileInfo = QSqlDatabase::addDatabase("QPSQL"); /* Had to add the "sql" line to the .pro file in string "QT =
            core \
            quick \
            widgets \
            sql
        */

    targetDbForScannedFileInfo.setHostName("localhost");
    targetDbForScannedFileInfo.setPort(5432); // This is the default port for postgres, so needs changing if you use a different RDBMS
    targetDbForScannedFileInfo.setDatabaseName("filmcab");
    targetDbForScannedFileInfo.setUserName("postgres");
    targetDbForScannedFileInfo.setPassword("postgres");

    // This is stupid. I don't want to pass in details about the file task in the constructor.  How to set data parameters?

    ProcessFilesTaskData *processFilesTaskData = new ProcessFilesTaskData();

    // try and connect.

    qDebug() << "main: Attempting to connect to:"
             << targetDbForScannedFileInfo.hostName()
             << targetDbForScannedFileInfo.port()
             << targetDbForScannedFileInfo.userName()
             << targetDbForScannedFileInfo.password();

    bool connectedToDb = targetDbForScannedFileInfo.open();
    processFilesTaskData->triedToConnect = true;

    if(!connectedToDb) {
        auto connectionError = targetDbForScannedFileInfo.lastError();
        qCritical() << "main:Error on attempting to open database:" << connectionError.text(); // Test this with bad pwd
        // Still soldiers on, should still be able to get through directory.
        processFilesTaskData->dbconnected = false; // Task should skip db work, do just the file stuff.
    }
    else {
        qDebug() << "main:Connected successfully!";
        processFilesTaskData->dbconnected = true;
    }

    processFilesTaskData->assumeFileTypeId = CommonFileTypes::torrent_file;
    processFilesTaskData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.

    processFilesTaskData->listOfFileTypes = {"*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx", "*.vob" };
    processFilesTaskData->directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;
    processFilesTaskData->directoryIteratorFlags = QDirIterator::Subdirectories;
    processFilesTaskData->targetLayer = TargetLayer::stage_for_master;
    processFilesTaskData->skip_db_writes_even_if_connected = true; // We want to test the directory stuff, and we don't have updates set up.
    processFilesTaskData->tableNameToWriteNewRecordsTo = "files"; // dur.

    // So, this looks sus, but I create a task WITH data.

    qDebug("main:ProcessFilesTask *processFilesTask = new ProcessFilesTask(*processFilesTaskData, &a)");

    ProcessFilesTask *processFilesTask = new ProcessFilesTask(*processFilesTaskData, &a);

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
