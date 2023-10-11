/*
 * Put a header on it.
 *
 * This is a program and database called filmcab, Film Cabinet.
 *
 */
#include <QCoreApplication>
#include <QtCore> // QTimer
#include <QDebug>

#include "sharedenumerations.h"
#include "processfilestask.h"

int main(int argc, char *argv[])
{

    qDebug("main:QCoreApplication a(argc, argv)");
    QCoreApplication qCoreApplicationInstance(argc, argv);

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

    ProcessFilesTaskData *processTorrentDownloadsTaskData = new ProcessFilesTaskData();

    // try and connect.

    qDebug() << "main: Attempting to connect to:"
             << targetDbForScannedFileInfo.hostName()
             << targetDbForScannedFileInfo.port()
             << targetDbForScannedFileInfo.userName()
             << targetDbForScannedFileInfo.password();

    bool connectedToDb = targetDbForScannedFileInfo.open();
    processTorrentDownloadsTaskData->triedToConnect = true;

    // A failed connection doesn't stop it from running, in case there's file work that can be done. Probably not, though.

    if(!connectedToDb) {
        QSqlError connectionError = targetDbForScannedFileInfo.lastError();
        qCritical() << "main:Error on attempting to open database:" << connectionError.text(); // Test this with bad pwd: caught.
        // Still soldiers on, should still be able to get through directory.
        processTorrentDownloadsTaskData->dbconnected = false; // Task should skip db work, do just the file stuff.
    }
    else {
        qDebug() << "main:Connected successfully!";
        processTorrentDownloadsTaskData->dbconnected = true;
    }

    // Build a bean, struct of control parameters for the task ahead
    // This first set are the ones that won't change over the various folders we scan for new files.

    processTorrentDownloadsTaskData->listOfFileTypes = {"*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx", "*.vob" };
    processTorrentDownloadsTaskData->directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;
    processTorrentDownloadsTaskData->directoryIteratorFlags = QDirIterator::Subdirectories;
    processTorrentDownloadsTaskData->skip_db_writes_even_if_connected = false; // We want to test the directory stuff, and we don't have updates set up.

    processTorrentDownloadsTaskData->targetSchema = "stage_for_master";
    processTorrentDownloadsTaskData->tableNameToWriteNewRecordsTo = "files"; // dur. Da table.

    // Copy this to two more packets to pass in.

    ProcessFilesTaskData processPublishedFilesTaskData = ProcessFilesTaskData(*processTorrentDownloadsTaskData);
    ProcessFilesTaskData processBackedupFilesTaskData = ProcessFilesTaskData(*processTorrentDownloadsTaskData);

    processTorrentDownloadsTaskData->assumeFileTypeId = CommonFileTypes::torrent_file;
    processTorrentDownloadsTaskData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.

    processPublishedFilesTaskData.assumeFileTypeId = CommonFileTypes::published_file;
    processPublishedFilesTaskData.searchPath = "O:/Video AllInOne";

    processBackedupFilesTaskData.assumeFileTypeId = CommonFileTypes::backedup_file;
    processBackedupFilesTaskData.searchPath = "G:/Video AllInOne2";

    // So, this looks sus, but I create a task WITH data.

    qDebug("main:ProcessFilesTask *processFilesTask = new ProcessFilesTask(*processFilesTaskData, &qCoreApplicationInstance)");

    // Test that single task still works.

    ProcessFilesTask *processFilesTask = new ProcessFilesTask(*processTorrentDownloadsTaskData, &qCoreApplicationInstance);

    qDebug("main:QObject::connect(processFilesTask, SIGNAL(finished()), &a, SLOT(quit()))");
    QObject::connect(processFilesTask, SIGNAL(finished()), &qCoreApplicationInstance, SLOT(quit())); // or SLOT(close()?
    // This will run the task from the application event loop.

    // Asynchronous run (start) the task.
    // Every call to QTimer::singleShot(...) is executed on the event loop of the thread where it is invoked **. If invoked from the main thread, it'll be the event loop started with app.exec().
    qDebug("main:QTimer::singleShot(0, processFilesTask, SLOT(run()))");
    QTimer::singleShot(0, processFilesTask,
                       SLOT(run()) // run is called from the dispatch context, where it is safe to change window contents.
                  );

    // exit(non-zero)?

    qDebug("main:int returnvalue = a.exec()");
    int returnvalue = qCoreApplicationInstance.exec(); // Now! the "run()" is pulled off the event queue and run.
    qDebug("main:returned value = %d", returnvalue);
    return returnvalue;
}
