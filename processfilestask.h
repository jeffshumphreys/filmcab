/*
 * TODO:
 *   check-in code
 *   backup database
 *   pull all directories out of name into directories table.
 *   grab all dates stamps on all directories (get traverse to work?)
 *   create batch run table and track
 *   capture code in batch run if changed
 *   update trigger:
 *      Maybe separate out parent folders?  For TV episodes the parent folder is often the series name, or the season name, like some MST3K seasons
 *      Test if I can shrink files table size by compressing the text field.  So far it's up to 3.9M and much more to go.  Also, maybe move the paths to different table? Minus the search_path? so strip the "D:/qBittorrent Downloads/Video/Movies" pre-text out, and that should really help
 *      same path different hash?
 *      same folder different name same hash?
 *      base name correct to path?
 *      text possibly truncated (max width)
 *      empty string?
 *      trailing spaces?
 *   Record that we successfully connected.  When it fails, we can recognize that we have successfully connected for n years or something, so it's something that had been fine.
 *   move this to generic file processing function. Pass in path, filters, target table and connection.
 *   switch for either staging should never collide, or merging, probably will collide
 *   capture container directories and search paths in table
 *   normalize directory from folder an maybe path?
 *   detect file content type? Text? bin? video?
 *   skip any srts with "French", "Port", "Span", German", etc.
 *   add local tz to file date times, for consistency
 *   add timing, total time, time/row, time for hash calc
 *   need a verification algorithm to set last_verified_full_path_present_on_ts_wth_tz
 *   add searches for O:\All in one\video
 *   add searches for G:\All in one2\video
 *   detect each folder: any change? No, then mark and skip. Assume all files still present.
 *   if target populated, copy it to mirror and date it.
 *   capture covers, .nfo, credits.txt
 *   Torrent_downloaded_from_Demonoid.me.txt
 *   dump samples
 *   tokenize file names rather than just split on "."
 *   add search_path_id that file came from, perhaps the filters used.
 *   look at all the NOT matching extensions
 *
 * OBSERVATIONS:
 *   D drive and O drive have MASSIVELY different performance times.
 *   Can't wait to check the G drive. Are all external drives this slow? Is it USB 2.0, 3.0, 3.1,etc?
 *   Maybe need that behemoth box with internal hard drives over network. Or switch for downloads and video publishing.
 */

#ifndef PROCESSFILESTASK_H
#define PROCESSFILESTASK_H

#include "task.h"
#include <QMainWindow>
#include <QObject>
#include <QQuickItem>
#include <QSharedDataPointer>
#include <QWidget>
#include <QFileSystemModel>
#include <QTreeView>
#include <QCryptographicHash>
//#include <QtMultimedia/QtMultimedia> // Will use eventually, or try, in order to get codec properties of video files.
#include <QSqlDatabase>  // Requires "sql" added to .pro file
#include <QSqlError> // Required to not get "Calling 'lastError' with incomplete return type 'QSqlError'" on lastError
#include <QSqlQuery>

class ProcessFilesTaskData;

class ProcessFilesTask : public Task
{
    Q_OBJECT
    QML_ELEMENT
public:
    ProcessFilesTask(QObject * = 0);

    ProcessFilesTask(const ProcessFilesTask &);
    ProcessFilesTask &operator=(const ProcessFilesTask &);
    ~ProcessFilesTask();

private:
    QSharedDataPointer<ProcessFilesTaskData> data;

    int traverseDirectoryHierarchy(const QString &dirname, QStringList listOfFileTypes, int filecount = 0)
    {
        QDir dir(dirname);
        dir.setNameFilters(listOfFileTypes);
        dir.setFilter(QDir::Dirs | QDir::Files | QDir::NoSymLinks | QDir::NoDot | QDir::NoDotDot);

        foreach (QFileInfo fileInfo, dir.entryInfoList()) {
            if (fileInfo.isDir() && fileInfo.isReadable())
                filecount = traverseDirectoryHierarchy(fileInfo.filePath(), listOfFileTypes, filecount);
            else {
                //qDebug() << fileInfo.filePath();
               filecount++; // Not working, is it counting folders instead?
            }
        }
        return filecount;
    }

public slots:
    void run()
    {
        qDebug("ProcessFilesTask::run()");
        QElapsedTimer timer;
        timer.start();
        // Connect to db so we can push the files found to a persistent store.

        QSqlDatabase filedb = QSqlDatabase::addDatabase("QPSQL"); /* Had to add the "sql" line to the .pro file in string "QT =
            core \
            quick \
            widgets \
            sql
        */

        filedb.setHostName("localhost");
        filedb.setPort(5432);
        filedb.setDatabaseName("genericdatabase");
        filedb.setUserName("postgres");
        filedb.setPassword("postgres");

        // TODO:

        qDebug() << "Attempting to connect to:" << filedb.hostName() << filedb.port() << filedb.userName() << filedb.password();

        bool connected = filedb.open();

        if(!connected) {
            auto connectionError = filedb.lastError();
            qCritical() << "Error on attempting to open database:" << connectionError.text();
            // Still soldiers on, should still be able to get through directory.
        }
        else {
            qDebug() << "Connected successfully!";
            //QSqlQuery q(db);
            //q.exec("SET NAMES latin1");
        }

        // Agh! it's staging!!!! if (connected) filedb.transaction();

        // TODO: set a default schema? Reduce custom code.

        //if (connected) QSqlQuery("TRUNCATE TABLE stage_for_master.files RESTART IDENTITY", filedb); // Throwaway TODO: Need a transaction? NO. Not on staging. Der. On the master schema, if I ever get there(!), then I'll need transactions.

        // Start processing the files I have, movies and TV, torrented files, cleaned up, and backup files, and eventually cleaned and reduced bit width files.
        // On primary is to grab create and modify dates, sizes, and an MD5 hash for matching when names change.

        int howManyFilesReadInfoFor = 0; // Now that I'm skipping files, I like to know how many were grabbed
        int howManyFilesPreppedFromDirectoryScan = 0; // ambiguous name
        int howManyFilesProcessed = 0; // including failures
        int howManyFilesProcessedSuccessfully = 0; // Not necessarily added.
        int howManyFilesAddedToDatabaseNewly = 0;
        int limitedToExaminingFilesFromDirectoryScan = 0; // 0 means don't apply limit

        // Search directories

        QString FilesBaseDirectory = "D:/qBittorrent Downloads/Video/Movies";
        FilesBaseDirectory = "D:/qBittorrent Downloads/Video/TV"; // 2nd search, so we didn't truncate, and didn't reset the IDENTITY.
        FilesBaseDirectory = "O:/Video AllInOne"; // 2nd search, so we didn't truncate, and didn't reset the IDENTITY.
        // Crashed on 2489 : "O:/Video AllInOne/_Police State/Network (1976).mkv". Got inserted though. I think I crashed it fiddling in the source code. :(
        // O:
        // G:
        // Torrents?
        qDebug() << "**** ProcessFilesTask:: Scanning " << FilesBaseDirectory;

        qDebug() << "**** ProcessFilesTask:: First get a fast count";

        QDir filesdir(FilesBaseDirectory);
        filesdir.setFilter(QDir::Files|QDir::NoDotDot|QDir::NoDotAndDotDot);
        QStringList listOfFileTypes = {"*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx", "*.vob" };
        filesdir.setNameFilters(listOfFileTypes);

        int numberOfFilesInDirectories = traverseDirectoryHierarchy(FilesBaseDirectory, listOfFileTypes); // Wrong count!

        qDebug() << "**** ProcessFilesTask:: number of files in directory and subdirectories: " << numberOfFilesInDirectories;

        // This is slow for testing, and in production we want this to only look at directories that have changed since last scan. Probably need to enhance traverseDirectoryHierarchy.

        QDirIterator FileDirectoriesIter(FilesBaseDirectory, listOfFileTypes, QDir::NoDotAndDotDot|QDir::Files, QDirIterator::Subdirectories);

        // Examine each file and create an MD5 for it and push it to the database

        while (FileDirectoriesIter.hasNext()) {
            howManyFilesReadInfoFor++;
            QFileInfo FileInfo = FileDirectoriesIter.nextFileInfo();

            // Very first thing we need to do, due to the CPU intensity of hashing files on external drives, is see if we have it already in our staging table.

            QString FilePath = FileInfo.filePath();
            QString FileName = FileInfo.completeBaseName(); // All the dots

            QString FilePathPrepped = FilePath;
            QString FileNamePrepped = FileName;

            if (FilePath.contains('\'')) {
               // apostrophes will break a SQL insert, so double them.
               FilePathPrepped = FilePath.replace("'", "''");
               FileNamePrepped = FileName.replace("'", "''"); // Warning string expansion. Increased string length
            }

            QSqlQuery checkIfFilmInfoAlreadyinStagingDatabase;
            QString checkAlreadyCommand = QString("SELECT 1 FROM stage_for_master.files where text = '%1'").arg(FilePathPrepped);
            if (!checkIfFilmInfoAlreadyinStagingDatabase.exec(checkAlreadyCommand)) {
               qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastError().text();
               qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastQuery();
               break; // Query busted
            }
            int howManyRowsHadSamePath = checkIfFilmInfoAlreadyinStagingDatabase.numRowsAffected();

            if (howManyRowsHadSamePath == -1) {
               qDebug() << "Error: unable to run query that shows if path already in database. quitting.";
               break;
            }

            if (howManyRowsHadSamePath >= 1) {
               qDebug() << "**** ProcessFilesTask:: this file_path already in:" << FilePath << ", skipping because we know that''s where we crashed. Elsewhise we''d have to check dates, size, hash, etc.";
               continue;
            }
            QString parentFolderOfFile = FileInfo.dir().absolutePath();
            QFileInfo FileContainerInfo = QFileInfo(parentFolderOfFile);
            QDateTime fileContainerCreatedOn = FileContainerInfo.birthTime();
            QDateTime fileContainerModifiedOn = FileContainerInfo.lastModified();

            howManyFilesPreppedFromDirectoryScan++;
            if (howManyFilesPreppedFromDirectoryScan > limitedToExaminingFilesFromDirectoryScan && limitedToExaminingFilesFromDirectoryScan != 0) {
                qDebug() << "**** ProcessFilesTask:: Reached imposed limit of" << limitedToExaminingFilesFromDirectoryScan << "for testing, stopping";
                break;
            }

            QString FileNameExtension = FileInfo.suffix(); // Just the last suffix, not all the dots

            qint64 FileSize = FileInfo.size();
            QDateTime FileCreatedOn = FileInfo.birthTime();
            QDateTime FileModifiedOn = FileInfo.lastModified();

            QFile * fileObject = new QFile(FilePath);
            fileObject->open(QIODevice::ReadOnly);  // Note that torrent files will not be still downloading, only the final completed file is in this folder.
            QByteArray fileData = fileObject->readAll();

            // Construct a unique hash identifier for compare

            QByteArray fileHash = QCryptographicHash::hash(fileData, QCryptographicHash::Md5);
            if (howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "file hash is" << fileHash.length() << "bytes";  // Need size to define in file hash column. 8?
            QByteArray fileHashAsHex = fileHash.toHex();
            QString fileHashAsHexString = QString(fileHashAsHex);
            if (howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask:: " << FileName << " : " << fileHashAsHexString;

            // Write to database. If already there, update and increment find count and date range.
            // For now, let's just add them to the files table.  We'll worry about release year, name normalization, etc.
            // If hash changed, flag it and log. size, flag it and log. dates?

            if (connected) {
                if (howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask:: Starting attempt to add file info to files table...(stage_for_master.files)";
                qDebug() << howManyFilesPreppedFromDirectoryScan << ":" << FilePath;
                QSqlQuery pushFilmFileInfoToDatabase;
                QString insertCommand = QString("INSERT INTO stage_for_master.files(text, base_name, final_extension, type_id, record_version_for_same_name_file, file_md5_hash, file_deleted, file_size"
                                                ", file_created_on_ts, file_modified_on_ts, parent_folder_created_on_ts, parent_folder_modified_on_ts)"
                                                " VALUES ("
                                                /* id is an identity column since this is staging and so we don't need to keep a cross-table unique-ish id */
                                                "/* text */                                               '%1', " /* aka full_path */
                                                "/* base_name */                                          '%2', "
                                                "/* final_extension */                                    '%3', "
                                                "/* type_id: Downloaded Torrent File */                     8, " /* replace with var! */
                                                "/* This version (guess) and update should fix if trigger ever hit # */ 1, "
                                                "/* file_md5_hash */                                      '%4'::bytea, "
                                                "/* file_deleted */                               false,"
                                                "/* file_size */                                           %5 , "
                                                "/* file_created_on_ts */                                 '%6', "
                                                "/* file_modified_on_ts */                                '%7', "
                                                "/* parent_folder_created_on_ts */                        '%8', "
                                                "/* parent_folder_modified_on_ts */                       '%9'  "
                                                ")"
                                                //" ON CONFLICT ON CONSTRAINT files_text_version DO NOTHING" /* This is staging! so there should be no conflicts
                                                /* ON CONFLICT....*/ /* No unique constraint exactly since I'm holding deleted files in here */
                                                ).arg(
                                                   FilePathPrepped
                                                 , FileNamePrepped // Any other illegal characters? Check lengths first?
                                                 , FileNameExtension, fileHashAsHexString
                                                 , QString::number(FileSize)
                                                 , FileCreatedOn.toString("yyyy-MM-dd HH:mm:ss.ms") /* note that "ms" would be "fffffff" in sql server */
                                                 , FileModifiedOn.toString("yyyy-MM-dd HH:mm:ss.ms")
                                                 , fileContainerCreatedOn.toString("yyyy-MM-dd HH:mm:ss.ms")
                                                 , fileContainerModifiedOn.toString("yyyy-MM-dd HH:mm:ss.ms")
                                                 );

                // Did it successfully add a new record to the database?

                if (!pushFilmFileInfoToDatabase.exec(insertCommand)) {
                    qDebug() << pushFilmFileInfoToDatabase.lastError().text();
                    qDebug() << pushFilmFileInfoToDatabase.lastQuery();
                    qDebug() << "**** ProcessFilesTask:: Did not add this file info!";
                    /*
                     * ERROR:  duplicate key value violates unique constraint \"files_pkey\"\nDETAIL:  Key (id)=(1) already exists.\n(23505) QPSQL: Unable to create query
                     * ERROR:  duplicate key value violates unique constraint \"ax_files_text\"\nDETAIL:  Key (text)=(D:/qBittorrent Downloads/Video/Movies/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK.mkv) already exists.\n(23505) QPSQL: Unable to create query
                     */
                    howManyFilesProcessed++; // Still failed, though.
                    //filedb.rollback();
                    filedb.close();
                    break; // Transaction aborted so might as well stop.  Will have to think about that transaction thingy.
                }
                else {
                    if (howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask:: Writing file info to files table. Completed!";

                    howManyFilesAddedToDatabaseNewly++; // Not updated, which is not an error, but without the ON CONFLICT working we can't trap exactly.
                    howManyFilesProcessed++;
                    howManyFilesProcessedSuccessfully++; // Have to update this if I get ON CONFLICT and updates working, as that's processing.
                }
            }
        }

        // if (connected) filedb.commit(); // Good. Now visible to other users of db.

//        filesdir.setNameFilters(QStringList() << "*.*");
//        filesdir.setFilter(QDir::Files);
//        QStringList filenames = filesdir.entryList(); // entryInfoList
//        QString filenamesfound = filenames.join(", ");

        qint64 timeToRunInNanoSeconds = timer.nsecsElapsed();
        qint64 timeToRunInMicroSeconds = timeToRunInNanoSeconds / 1000;
        qint64 timeToRunInMilliSeconds = timeToRunInMicroSeconds / 1000;
        qint32 timeToRunInSeconds = timeToRunInMilliSeconds / 1000;
        qint32 timeToRunInMinutes = timeToRunInSeconds / 60;
        qint16 timeToRunInHours = timeToRunInMinutes / 60;

        qDebug("**** ProcessFilesTask:: How many minutes did the entire scan, hash, and insert take? %d", timeToRunInMinutes);
        qDebug("**** ProcessFilesTask:: How many file's infos were read from the directory scan: %d", howManyFilesReadInfoFor);
        qDebug("**** ProcessFilesTask:: How many file's infos were limiting run to from directory scans: %d", limitedToExaminingFilesFromDirectoryScan);
        qDebug("**** ProcessFilesTask:: How many file's infos were added to database newly: %d", howManyFilesAddedToDatabaseNewly);
        qDebug("**** ProcessFilesTask:: How many file's infos were processed: %d", howManyFilesProcessed); // A bit ambiguous since the update isn't in place.

        // ------------------------------------------------------------------------------------------------------------------------------------
        qDebug("ProcessFilesTask::run():emit finished()");
        emit finished();
    }

signals:
    void finished();

};

#endif // PROCESSFILESTASK_H
