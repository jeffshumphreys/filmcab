#include "processfilestask.h"
#include <QDebug>

class ProcessFilesTaskData : public QSharedData
{
public:

};

ProcessFilesTask::ProcessFilesTask(QObject *parent)
    : Task{parent}, data(new ProcessFilesTaskData)
{
    qDebug("ProcessFilesTask::ProcessFilesTask(QObject *parent)");
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

ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs)
    : data{rhs.data}
{
    qDebug("ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs): data{rhs.data}");
}

ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)
{
    qDebug("ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)");
    if (this != &rhs)
        data.operator=(rhs.data);
    return *this;
}

ProcessFilesTask::~ProcessFilesTask()
{

}
