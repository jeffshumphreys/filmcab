/*
 * Put a header on it.
 *
 * This is a program and database called filmcab, Film Cabinet.
 * Example of running: D:\qt_projects\filmcab>D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug\filmcab.exe -f "scan_folders_and_pull_file_details_into_database" -d filmcab

 *
 */
#include <QCoreApplication>
#include <QtCore> // QTimer
#include <QDebug>
#include "sharedenumerations.h"
#include "processfilestask.h"

bool showProgress = true;

void myMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();

    const char *file = context.file ? context.file : "";
    const char *function = context.function ? context.function : "";
    switch (type) {
    case QtDebugMsg:
        if (showProgress) {
            if (msg.count() == 0) {
                fprintf(stderr, ".");
            }
            fprintf(stderr, "Debug: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        }
        break;
    case QtInfoMsg:
        fprintf(stderr, "Info: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtWarningMsg:
        fprintf(stderr, "Warning: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s (%s:%u, %s)\n", localMsg.constData(), file, context.line, function);
        break;
    }
}

int main(int argc, char *argv[])
{

    qInstallMessageHandler(myMessageOutput);

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

    QCommandLineOption flowToExecute(QStringList()       << "f" << "flow-to-execute", QCoreApplication::translate("main", "execute the steps in this flow"),QCoreApplication::translate("main", "flownm")); // Only action for now.
    commandLineParser.addOption(flowToExecute);

    // A boolean option with a multiple options (-p, --showprogress)
    // Haven't implemented this, but it might reduce the flood

    QCommandLineOption showProgressOption(QStringList()  << "o" << "showprogress", QCoreApplication::translate("main", "Show progress during flow execution"));
    commandLineParser.addOption(showProgressOption);

    // Note that the sql is mostly postgres customized so using another driver will probably break it.  Also, you'll have to deploy the other drivers I think.

    QCommandLineOption databaseImpl(QStringList()        << "i" << "database-impl", QCoreApplication::translate("main", "database implementation"),QCoreApplication::translate("main", "dbimpl"), "QPSQL");
    commandLineParser.addOption(databaseImpl);

    QCommandLineOption connectToServerNm(QStringList()   << "s" << "dbserver", QCoreApplication::translate("main", "dbserver"),QCoreApplication::translate("main", "dbserver"), "localhost");
    commandLineParser.addOption(connectToServerNm);

    QCommandLineOption connectToServerPort(QStringList() << "t" << "dbserverport", QCoreApplication::translate("main", "dbserverport"),QCoreApplication::translate("main", "dbserverport"), "5432");
    commandLineParser.addOption(connectToServerPort);

    QCommandLineOption connectToDbNm(QStringList()       << "d" << "database", QCoreApplication::translate("main", "database"),QCoreApplication::translate("main", "db"), "<na>");
    commandLineParser.addOption(connectToDbNm);

    QCommandLineOption connectUser(QStringList()         << "u" << "dbuser", QCoreApplication::translate("main", "database user login"),QCoreApplication::translate("main", "dbuser"), "postgres"); // default postgres power user. NEVER USE!!!!!! EVAH!!!!
    commandLineParser.addOption(connectUser);

    QCommandLineOption connectPassword(QStringList()     << "p" << "dbpassword", QCoreApplication::translate("main", "database user's password"),QCoreApplication::translate("main", "dbpassword"), "postgres");
    commandLineParser.addOption(connectPassword);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Convert inputs to codes
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    commandLineParser.process(qCoreApplicationInstance);

    // Convert arguments into meaning

    // We are going to try to support multiple actions so as to reuse connections, queries, loops, task structure. Just scan for now.

    // get the directory passed in.  Fix later for actions that don't need a path.

    const QStringList args = commandLineParser.positionalArguments();

    if (args.count() > 0) {
        throw new MyException("Positional arguments not supported at this time.");
    }

    // We are going to try to support multiple actions so as to reuse connections, queries, loops, task structure. Just scan for now.

    QString reqFlowToExecute = commandLineParser.value(flowToExecute);

    if (reqFlowToExecute.isNull()) {
        throw new MyException("You must indicate a flow to execute, look in the receiving_dock.path_processing_flows; the txt field is the string here.");
    }

    // Will have to connect to database to verify flow exists.

    showProgress = commandLineParser.isSet(showProgressOption);

    QString dbimpl = commandLineParser.value(databaseImpl);
    QString dbserver = commandLineParser.value(connectToServerNm);
    QString dbserverport = commandLineParser.value(connectToServerPort);
    QString dbnm = commandLineParser.value(connectToDbNm);
    QString dbuser = commandLineParser.value(connectUser);
    QString dbpassword = commandLineParser.value(connectPassword);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Completed convert inputs to codes (as in, don't add any below this. (Duh.)
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Our hack testing control; should set from argument and/or gui or batch runner

    WhichTaskToRun whichTaskToRun = WhichTaskToRun::LoadVideoFileInfoIntoDatabase;

    QSqlDatabase targetDbTaskProcessing = QSqlDatabase::addDatabase(dbimpl); /* Had to add the "sql" line to the .pro file in string "QT =
            core \
            quick \
            widgets \
            sql
        */

    targetDbTaskProcessing.setHostName(dbserver);
    targetDbTaskProcessing.setPort(dbserverport.toInt());
    targetDbTaskProcessing.setDatabaseName(dbnm);
    targetDbTaskProcessing.setUserName(dbuser);
    targetDbTaskProcessing.setPassword(dbpassword);

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

        // Directory #1

        taskProcessingControlData = new ProcessFilesTaskData();
        taskProcessingControlData->directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;
        taskProcessingControlData->triedToConnect = triedToConnect;
        taskProcessingControlData->dbconnected = connectedToDb;
        taskProcessingControlData->directoryIteratorFlags = QDirIterator::Subdirectories;

        taskProcessingControlData->listOfFileTypes = {"*.avi", "*.f4v", "*.flv", "*.idx", "*.mkv", "*.mov", "*.mp4", "*.mpg", "*.ogv", "*.srt", "*.sub", "*.vob", "*.webm", "*.wmv" }; // sorted for ease of maintenance
        taskProcessingControlData->targetSchema = "stage_for_master";
        taskProcessingControlData->tableNameToWriteNewRecordsTo = "files"; // dur. Da table.
        taskProcessingControlData->assumeFileTypeId = CommonFileTypes::torrent_file;
        taskProcessingControlData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.
        taskProcessingControlData->file_flow_state_enum_str = "downloaded"; // see enum type in database
        taskProcessingControlData->searchPath = "D:/qBittorrent Downloads/Video/Movies"; // This and TV are my torrent downloads.

        // Directory #2

        ProcessFilesTaskData processPublishedFilesTaskData = ProcessFilesTaskData(*taskProcessingControlData); // Files we published for FireTV explorer to pick up.
        processPublishedFilesTaskData.assumeFileTypeId = CommonFileTypes::published_file;
        processPublishedFilesTaskData.file_flow_state_enum_str = "published"; // see enum type in database
        processPublishedFilesTaskData.searchPath = "O:/Video AllInOne";

        // Directory #3

        ProcessFilesTaskData processBackedupFilesTaskData = ProcessFilesTaskData(*taskProcessingControlData);
        processBackedupFilesTaskData.assumeFileTypeId = CommonFileTypes::backedup_file;
        processBackedupFilesTaskData.file_flow_state_enum_str = "backedup"; // written to files_batch_runs_log.file_flow_state column
        //processBackedupFilesTaskData.searchPath = "G:/Video AllInOne2"; // Shut down this location because I made so many changes to the root folders and reorganization, that I didn't want to pollute the backup space with a zillion duplicates.
        processBackedupFilesTaskData.searchPath = "G:/Video AllInOne Backup"; // Better name anyways. So now any references in files to AllInOne2 are broken, and need to marked as deleted?

        // Directories #1, #2, #3

        processSetOfFilesTasksData.processFilesTasksData = {*taskProcessingControlData, processPublishedFilesTaskData, processBackedupFilesTaskData};
//    }
//    else if (whichTaskToRun == WhichTaskToRun::ImportExcelVideoFilesToDatabase) {
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
    taskProcessingControlData->showProgress = showProgress;
    ProcessFilesTask *processFilesTasks;

    // Test when passing in multiple search paths if they all get processed sequentially.

    processFilesTasks = new ProcessFilesTask(processSetOfFilesTasksData, &qCoreApplicationInstance);

    QObject::connect(processFilesTasks, SIGNAL(finished()), &qCoreApplicationInstance, SLOT(quit())); // or SLOT(close()?
    QTimer::singleShot(0, processFilesTasks, SLOT(run()));
    int returnvalue = qCoreApplicationInstance.exec(); // Now! the "run()" is pulled off the event queue and run.
    return returnvalue;
} // end main function


