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

    processTorrentDownloadsTaskData->listOfFileTypes = {"*.avi", "*.f4v", "*.flv", "*.idx", "*.mkv", "*.mov", "*.mp4", "*.mpg", "*.ogv", "*.srt", "*.sub", "*.vob", "*.webm", "*.wmv" }; // sorted for ease of maintenance
    processTorrentDownloadsTaskData->directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;
    processTorrentDownloadsTaskData->directoryIteratorFlags = QDirIterator::Subdirectories;

    processTorrentDownloadsTaskData->targetSchema = "stage_for_master";
    processTorrentDownloadsTaskData->tableNameToWriteNewRecordsTo = "files"; // dur. Da table.

    // Copy this to two more packets to pass in.

    ProcessFilesTaskData processPublishedFilesTaskData = ProcessFilesTaskData(*processTorrentDownloadsTaskData); // Files we published for FireTV explorer to pick up.
    ProcessFilesTaskData processBackedupFilesTaskData = ProcessFilesTaskData(*processTorrentDownloadsTaskData);

    processTorrentDownloadsTaskData->assumeFileTypeId = CommonFileTypes::torrent_file;
    processTorrentDownloadsTaskData->file_flow_state_enum_str = "downloaded"; // see enum type in database
    processTorrentDownloadsTaskData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.

    processPublishedFilesTaskData.assumeFileTypeId = CommonFileTypes::published_file;
    processPublishedFilesTaskData.file_flow_state_enum_str = "published"; // see enum type in database
    processPublishedFilesTaskData.searchPath = "O:/Video AllInOne";

    processBackedupFilesTaskData.assumeFileTypeId = CommonFileTypes::backedup_file;
    processBackedupFilesTaskData.file_flow_state_enum_str = "backedup"; // written to files_batch_runs_log.file_flow_state column
    //processBackedupFilesTaskData.searchPath = "G:/Video AllInOne2"; // Shut down this location because I made so many changes to the root folders and reorganization, that I didn't want to pollute the backup space with a zillion duplicates.
    processBackedupFilesTaskData.searchPath = "G:/Video AllInOne Backup"; // Better name anyways. So now any references in files to AllInOne2 are broken, and need to marked as deleted?

    // So, this looks sus, but I create a task WITH data.

    qDebug("main:ProcessFilesTask *processFilesTask = new ProcessFilesTask(*processFilesTaskData, &qCoreApplicationInstance)");

    bool testSingleTask = false;  // true and just run the torrent downloads scan.

    // Test that single task still works.
    if (testSingleTask) {
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
    }

    // Test when passing in multiple search paths if they all get processed sequentially.

    else {
        ProcessFilesTasksData processFilesTasksData;
        processFilesTasksData.processFilesTasksData = {*processTorrentDownloadsTaskData, processPublishedFilesTaskData};
        ProcessFilesTask *processFilesTasks = new ProcessFilesTask(processFilesTasksData, &qCoreApplicationInstance);
        qDebug("main:QObject::connect(processFilesTasks, SIGNAL(finished()), &a, SLOT(quit()))");
        QObject::connect(processFilesTasks, SIGNAL(finished()), &qCoreApplicationInstance, SLOT(quit())); // or SLOT(close()?
        qDebug("main:QTimer::singleShot(0, processFilesTasks, SLOT(run()))");
        QTimer::singleShot(0, processFilesTasks, SLOT(run()));
    }

   // exit(non-zero)?

    qDebug("main:int returnvalue = a.exec()");
    int returnvalue = qCoreApplicationInstance.exec(); // Now! the "run()" is pulled off the event queue and run.
    qDebug("main:returned value = %d", returnvalue);
    return returnvalue;
}
