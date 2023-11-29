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
//#include "importexcelfilestask.h"

int main(int argc, char *argv[])
{

    // deployed: windeployqt --debug --verbose 2 D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug

    qDebug("main:QCoreApplication a(argc, argv)");

    QCoreApplication qCoreApplicationInstance(argc, argv);

    // Let's get snazzy.  This is a command-line tool; I'm not eager to make this a dll lib to incorporate in a big gui app.
    // So we are more into the arguments we can pass, which means all the magic numbers and strings in main will hopefully go away.

    QCoreApplication::setApplicationName("filmcab processor");
    QCoreApplication::setApplicationVersion("1.0");  // I think we're in a more 1.1 state since I'm running the debug exe from powershell once and a while, but the magic strings are still here and it's not pulling from arguments the folders and stuff, so 1.0.
    QCoreApplication::setOrganizationName("personal, not an organization"); // Trying to be clear that there is no business here, no IPO, just me.  No such plan, either.

    // We'll use the parser qt gives us, so as to be standardized for any user.

    QCommandLineParser commandLineParser;
    commandLineParser.setApplicationDescription("Command line tool to process files and videos into more usable spaces, publish and track for duplicates, clean names");
    commandLineParser.addHelpOption();
    commandLineParser.addVersionOption();
    commandLineParser.addPositionalArgument("source", QCoreApplication::translate("main", "Path to recursively scan for new files."));

    // A boolean option with a multiple options (-p, --showprogress)
    QCommandLineOption showProgressOption(QStringList() << "p" << "showprogress", QCoreApplication::translate("main", "Show progress during scan"));
    commandLineParser.addOption(showProgressOption);

    QCommandLineOption connectUser(QStringList() << "u" << "dbuser", QCoreApplication::translate("main", "database user login"),QCoreApplication::translate("main", "dbuser"), "postgres");
    commandLineParser.addOption(connectUser);

    QCommandLineOption action(QStringList() << "a" << "action-to-execute", QCoreApplication::translate("main", "execute process named this"),QCoreApplication::translate("main", "procact"), "scan");

    commandLineParser.addOption(action);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Convert inputs to codes
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    commandLineParser.process(qCoreApplicationInstance);

    // Convert arguments into meaning

    QString reqAction = commandLineParser.value(action);

    const QStringList args = commandLineParser.positionalArguments();

    if (args.count() < 1) {
        throw new MyException("A directory is required for scanning.");
    }

    QString scanDirectory = args.at(0);

    bool showProgress = commandLineParser.isSet(showProgressOption);

    // D:\qt_projects\filmcab>D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug\filmcab.exe -a scan "D:\qBittorrent Downloads\Video\Movies"


    // Our hack testing control; should set from argument and/or gui or batch runner

    WhichTaskToRun whichTaskToRun = WhichTaskToRun::LoadVideoFileInfoIntoDatabase;

    QSqlDatabase targetDbTaskProcessing = QSqlDatabase::addDatabase("QPSQL"); /* Had to add the "sql" line to the .pro file in string "QT =
            core \
            quick \
            widgets \
            sql
        */

    targetDbTaskProcessing.setHostName("localhost");
    targetDbTaskProcessing.setPort(5432); // This is the default port for postgres, so needs changing if you use a different RDBMS
    targetDbTaskProcessing.setDatabaseName("filmcab");
    targetDbTaskProcessing.setUserName("postgres");
    targetDbTaskProcessing.setPassword("postgres");

    // try and connect.

    qDebug() << "main: Attempting to connect to:"
             << targetDbTaskProcessing.hostName()
             << targetDbTaskProcessing.port()
             << targetDbTaskProcessing.userName()
             << targetDbTaskProcessing.password();

    bool connectedToDb = targetDbTaskProcessing.open();
    bool triedToConnect = true;

    // A failed connection doesn't stop it from running, in case there's file work that can be done. Probably not, though.

    if(!connectedToDb) {
        QSqlError connectionError = targetDbTaskProcessing.lastError();
        qCritical() << "main:Error on attempting to open database:" << connectionError.text(); // Test this with bad pwd: caught.
        // Still soldiers on, should still be able to get through directory.

    }
    else {
        qDebug() << "main:Connected successfully to" << targetDbTaskProcessing.hostName() << "as" << targetDbTaskProcessing.userName() << "on" << targetDbTaskProcessing.port();
    }

    // Build a bean, struct of control parameters for the task ahead
    // This first set are the ones that won't change over the various folders we scan for new files.

    ProcessFilesTaskData *taskProcessingControlData;

    ProcessFilesTasksData processSetOfFilesTasksData;

    if (whichTaskToRun == WhichTaskToRun::LoadVideoFileInfoIntoDatabase) {
        taskProcessingControlData = new ProcessFilesTaskData();
        taskProcessingControlData->directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;
        taskProcessingControlData->triedToConnect = triedToConnect;
        taskProcessingControlData->dbconnected = connectedToDb;
        taskProcessingControlData->directoryIteratorFlags = QDirIterator::Subdirectories;

        taskProcessingControlData->listOfFileTypes = {"*.avi", "*.f4v", "*.flv", "*.idx", "*.mkv", "*.mov", "*.mp4", "*.mpg", "*.ogv", "*.srt", "*.sub", "*.vob", "*.webm", "*.wmv" }; // sorted for ease of maintenance
        taskProcessingControlData->targetSchema = "stage_for_master";
        taskProcessingControlData->tableNameToWriteNewRecordsTo = "files"; // dur. Da table.
        taskProcessingControlData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.
        taskProcessingControlData->assumeFileTypeId = CommonFileTypes::torrent_file;
        taskProcessingControlData->file_flow_state_enum_str = "downloaded"; // see enum type in database
        taskProcessingControlData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.

        ProcessFilesTaskData processPublishedFilesTaskData = ProcessFilesTaskData(*taskProcessingControlData); // Files we published for FireTV explorer to pick up.
        processPublishedFilesTaskData.assumeFileTypeId = CommonFileTypes::published_file;
        processPublishedFilesTaskData.file_flow_state_enum_str = "published"; // see enum type in database
        processPublishedFilesTaskData.searchPath = "O:/Video AllInOne";

        ProcessFilesTaskData processBackedupFilesTaskData = ProcessFilesTaskData(*taskProcessingControlData);
        processBackedupFilesTaskData.assumeFileTypeId = CommonFileTypes::backedup_file;
        processBackedupFilesTaskData.file_flow_state_enum_str = "backedup"; // written to files_batch_runs_log.file_flow_state column
        //processBackedupFilesTaskData.searchPath = "G:/Video AllInOne2"; // Shut down this location because I made so many changes to the root folders and reorganization, that I didn't want to pollute the backup space with a zillion duplicates.
        processBackedupFilesTaskData.searchPath = "G:/Video AllInOne Backup"; // Better name anyways. So now any references in files to AllInOne2 are broken, and need to marked as deleted?

        processSetOfFilesTasksData.processFilesTasksData = {*taskProcessingControlData, processPublishedFilesTaskData, processBackedupFilesTaskData};
    }
    else if (whichTaskToRun == WhichTaskToRun::ImportExcelVideoFilesToDatabase) {
//        taskProcessingControlData = new ImportExcelFilesTaskData();
//        taskProcessingControlData->triedToConnect = triedToConnect;
//        taskProcessingControlData->dbconnected = connectedToDb;
//        ImportExcelFilesTaskData *importExcelFileControlData = static_cast<ImportExcelFilesTaskData *>(taskProcessingControlData);
//        importExcelFileControlData->listOfFileTypes = {"*.xlsx" };
//        importExcelFileControlData->directoryIteratorFlags = QDirIterator::NoIteratorFlags; // For now we don't want to go crazy
//        importExcelFileControlData->targetSchema = "receiving_deck";
//        importExcelFileControlData->tableNameToWriteNewRecordsTo = "excel_sheet_all_the_videos"; // Maybe....all the tv series?
//        importExcelFileControlData->loadedSpreadsheet = false;
//        processSetOfFilesTasksData.processFilesTasksData = {*importExcelFileControlData};

    }
    else {
        throw new MyException("Unimplemented WhichTaskToRun. aborting.");
    }

    taskProcessingControlData->triedToConnect = triedToConnect;
    taskProcessingControlData->dbconnected = connectedToDb;

    bool testSingleTask = false;  // true and just run the torrent downloads scan.
    ProcessFilesTask *processFilesTasks;

    // Test that single task still works.

    if (testSingleTask) {
        processFilesTasks = new ProcessFilesTask(processSetOfFilesTasksData.processFilesTasksData[0], &qCoreApplicationInstance);
    }

    // Test when passing in multiple search paths if they all get processed sequentially.

    else {
        processFilesTasks = new ProcessFilesTask(processSetOfFilesTasksData, &qCoreApplicationInstance);
    }

    qDebug("main:QObject::connect(processFilesTasks, SIGNAL(finished()), &a, SLOT(quit()))");
    QObject::connect(processFilesTasks, SIGNAL(finished()), &qCoreApplicationInstance, SLOT(quit())); // or SLOT(close()?
    qDebug("main:QTimer::singleShot(0, processFilesTasks, SLOT(run()))");
    QTimer::singleShot(0, processFilesTasks, SLOT(run()));

    qDebug("main:int returnvalue = a.exec()");
    int returnvalue = qCoreApplicationInstance.exec(); // Now! the "run()" is pulled off the event queue and run.
    qDebug("main:returned value = %d", returnvalue);
    return returnvalue;
} // end main function


