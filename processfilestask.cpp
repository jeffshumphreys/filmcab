#include "processfilestask.h"
#include "processfilestaskdata.h"

#include <QDebug>

ProcessFilesTask::ProcessFilesTask(QObject *parent, int assumeFileTypeId)
    : Task{parent}, data(new ProcessFilesTaskData)
{
    qDebug("ProcessFilesTask::ProcessFilesTask(QObject *parent, int assumeTypeId)");
    this->assumefileTypeId = assumeFileTypeId; // should verify it's in the type database, but I think RI is enabled, and if not, then there's a reason to keep dangling types.

    // QSqlDatabase filedb = QSqlDatabase::addDatabase("QPSQL")
    // Pass in: QSqlDatabase already set. Open? hmmmm
    // QDir::Dirs | QDir::Files | QDir::NoSymLinks | QDir::NoDot | QDir::NoDotDot)
    //filedb.setHostName("localhost");
    //filedb.setPort(5432);
    //filedb.setDatabaseName("genericdatabase");
    //filedb.setUserName("postgres");
    //filedb.setPassword("postgres");
    // default schema
    // staging dump and load? or master merge?
    // Search path
    // "*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx", "*.vob"
    // iterator flags
    // target table: files
    // file path column name: text
    // Crash if collision, or update if collision on path, or ignore and continue, or return silent no crash, or count
    // Skip database and hash
    // impose a test limit
    // sql type: Postgres
    // mask for dates: yyyy-MM-dd HH:mm:ss.ms
    // binary mapping
    // file type these files are:
        // 8: Downloaded Torrent File
        // 9: Published and name cleaned up from torrent
        // 10: Backed up from published folders
}

ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs) // Creates a new object with the data of the other
    : data{rhs.data}
{
    qDebug("ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs): data{rhs.data}");
}

ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs) // Assigns the data of another object to this object
{
    qDebug("ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)");
    if (this != &rhs)
        data.operator=(rhs.data);
    return *this;
}

ProcessFilesTask::~ProcessFilesTask()
{

}
