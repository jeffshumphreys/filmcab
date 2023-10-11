/*
 * TODO:
 *   check-in code
 *   backup database
 *   do torrents folder
 *   fix file types to published and renamed for view browsing, backedup from view browsing, magnet files for torrents
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
 *   D drive and O drive have MASSIVELY different performance times. G is surprisingly faster and is external. D is internal, O is external.
 *   Can't wait to check the G drive. Are all external drives this slow? Is it USB 2.0, 3.0, 3.1,etc?
 *   Maybe need that behemoth box with internal hard drives over network. Or switch for downloads and video publishing.
 *   vacuum'd full the stage_for_master schema. Dropped files table space from 10M to 9M.
 */

#ifndef PROCESSFILESTASK_H
#define PROCESSFILESTASK_H

#include "sharedenumerations.h"
#include "task.h" // empty of much
#include "processfilestaskdata.h" // our detail of request, where to look, what to expect when your expecting, database connection, search path, file type to classify these as.

#include <QObject>
#include <QSharedDataPointer> // Will we use? How?
#include <QFileSystemModel>
#include <QCryptographicHash>
#include <QSqlDatabase>  // Requires "sql" added to .pro file
#include <QSqlError> // Required to not get "Calling 'lastError' with incomplete return type 'QSqlError'" on lastError
#include <QSqlQuery>

class ProcessFilesTaskData;

class ProcessFilesTask : public Task
{
    Q_OBJECT
public:
    // What a mess. I need to pass data, or controls in, but I don't need arguments out the kazoo.
    ProcessFilesTask(ProcessFilesTaskData &processFilesTaskData, QObject * = 0);
    ProcessFilesTask(ProcessFilesTaskData processFilesTaskData[], QObject * = 0);
    ProcessFilesTask(const ProcessFilesTask &);
    ProcessFilesTask &operator=(const ProcessFilesTask &);
    ~ProcessFilesTask();

private:
    QSharedDataPointer<ProcessFilesTaskData> data; // Set in constructor. Creator needs to populate.

    // Right now I'm just using this to count files.
    int traverseDirectoryHierarchy(const QString &dirname, QStringList listOfFileTypes, int filecount = 0)
    {
        QDir dir(dirname);
        dir.setFilter(QDir::Dirs | QDir::Files | QDir::NoSymLinks | QDir::NoDot | QDir::NoDotDot); // This argument should be passed in

        foreach (QFileInfo fileInfo, dir.entryInfoList()) {
            if (fileInfo.isDir() && fileInfo.isReadable()) {
                qDebug() << "Is a directory:" << fileInfo.filePath() << "--" << filecount;
                filecount = traverseDirectoryHierarchy(fileInfo.filePath(), listOfFileTypes, filecount);
        } else {
                qDebug() << "not a directory:" << fileInfo.filePath() << "--" << filecount;
                // Suffixes are "*.mkv" style, suffix() is just "mkv"
                if (listOfFileTypes.contains("*." + fileInfo.suffix(), Qt::CaseSensitivity::CaseInsensitive)) {
                    filecount++; // Not working, is it counting folders instead?
                }
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

        QSqlDatabase filedb = data->db;
        bool connected = data->dbconnected; // Caller should have connected us.

        qint64 fileTypeId = data->assumeFileTypeId;
        if (fileTypeId == 0) { fileTypeId = CommonFileTypes::file; } // A default duh, but not super useful.

        // Agh! it's staging!!!! if (connected) filedb.transaction();

        // TODO: set a default schema? Reduce custom code.

        //if (connected) QSqlQuery("TRUNCATE TABLE stage_for_master.files RESTART IDENTITY", filedb); // Throwaway TODO: Need a transaction? NO. Not on staging. Der. On the master schema, if I ever get there(!), then I'll need transactions.

        // Start processing the files I have, movies and TV, torrented files, cleaned up, and backup files, and eventually cleaned and reduced bit width files.
        // On primary is to grab create and modify dates, sizes, and an MD5 hash for matching when names change.

        int howManyFilesReadInfoFor = 0; // Now that I'm skipping files, I like to know how many were grabbed
        int howManyFilesPreppedFromDirectoryScan = 0; // ambiguous name
        int howManyFilesProcessed = 0; // including failures
        int howManyFilesProcessedSuccessfully = 0; // Not necessarily added. What does "Successfully" mean?  Added? Skipped? Serious failures tend to stop the program.
        int howManyFilesAddedToDatabaseNewly = 0;
        int limitedToExaminingFilesFromDirectoryScan = 0; // 0 means don't apply limit

        // Search directories

        QString searchBaseDirectory = data->searchPath;
        if (!QDir(searchBaseDirectory).exists()) {
            // https://doc.qt.io/qt-5/debug.html
            qCritical() << "**** ProcessFilesTask:: Search base directory" << searchBaseDirectory << "not found. exiting.";
            qDebug("ProcessFilesTask::run():emit finished() (1)"); // Is this the correct way to exit? No clue.
            emit finished();
            return;
        }

        QString targetTableForFileInfo = data->tableNameToWriteNewRecordsTo;
        QString targetSchemaForFileInfo = data->targetSchema;

        qDebug() << "**** ProcessFilesTask:: Scanning " << searchBaseDirectory;

        qDebug() << "**** ProcessFilesTask:: First get a fast count";

        QDir searchForFilesDir(searchBaseDirectory);

        searchForFilesDir.setFilter(QDir::Files|QDir::NoDotDot|QDir::NoDotAndDotDot);
        QStringList listOfFileTypes = data->listOfFileTypes;
        searchForFilesDir.setNameFilters(listOfFileTypes);

        int numberOfFilesInDirectories = traverseDirectoryHierarchy(searchBaseDirectory, listOfFileTypes); // Wrong count!

        qDebug() << "**** ProcessFilesTask:: number of files in directory and subdirectories: " << numberOfFilesInDirectories;

        // This is slow for testing, and in production we want this to only look at directories that have changed since last scan. Probably need to enhance traverseDirectoryHierarchy.

        QDirIterator FileDirectoriesIter(searchBaseDirectory, listOfFileTypes, QDir::NoDotAndDotDot|QDir::Files, QDirIterator::Subdirectories);

        // Examine each file and create an MD5 for it and push it to the database

        QElapsedTimer timeThisFileProcess; // Time each file processing, including generating the hash, reading in the entire file, writing to the database.
        timeThisFileProcess.start();

        while (FileDirectoriesIter.hasNext()) {
            timeThisFileProcess.restart(); // Otherwise it doesn't reset for some smart reason.
            howManyFilesReadInfoFor++;
            QFileInfo FileInfo = FileDirectoriesIter.nextFileInfo();

            // Very first thing we need to do, due to the CPU intensity of hashing files on external drives, is see if we have it already in our staging table.

            QString FilePath = FileInfo.filePath();
            QString FileName = FileInfo.completeBaseName(); // All the dots in the name are included except the last . to the final extensions. (torrent thing)

            QString FilePathPrepped = FilePath;
            QString FileNamePrepped = FileName;

            if (FilePath.contains('\'')) {
               // apostrophes will break a SQL insert, so double them.
               FilePathPrepped = FilePath.replace("'", "''");
               FileNamePrepped = FileName.replace("'", "''"); // Warning string expansion. Increased string length
            }

            // I've half-designed this to run without writing to the database, mostly for testing the non-db parts.

            if (connected) {
                QSqlQuery checkIfFilmInfoAlreadyinStagingDatabase;
                // This is more cross-db compatible than using database-specific things. Even if ON CONFLICT were in ANSI, it's not in SQL Server, I know that for sure.
                // Hopefully, the unique constraint is in place so that null record_deleted can be a series of deleted rows
                QString checkAlreadyCommand = QString("SELECT 1 FROM %3.%2 WHERE txt = '%1' AND record_deleted = false").arg(FilePathPrepped, targetTableForFileInfo, targetSchemaForFileInfo);

                if (!checkIfFilmInfoAlreadyinStagingDatabase.exec(checkAlreadyCommand)) {
                   qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastError().text();
                   qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastQuery();
                   break; // Query busted
                }
                int howManyRowsHadSamePath = checkIfFilmInfoAlreadyinStagingDatabase.numRowsAffected();

                if (howManyRowsHadSamePath == -1) {
                   qCritical() << "Error: unable to run query that shows if path already in database. quitting.";
                   break;
                }

                // error if more than one record matches full path and is not deleted, because then our vision is invalid (only one undeleted row per path is supported.)
                // Note that cross system dups could cause this violation if more than one computer involved.

                if (howManyRowsHadSamePath > 1) {
                   qCritical() << "**** ProcessFilesTask:: More than one undeleted record for this file path was found, which is outside universal expectations. Stopping.";
                   break;
                }
                else if (howManyRowsHadSamePath == 1) {
                   qDebug() << "**** ProcessFilesTask:: this file_path already in files table. updating that we saw file.";
                   // UPDATE table set last_verified_full_path_present_on_ts_wth_tz to now.
                   QString updRecAlreadyCommand = QString("UPDATE %3.%2 SET last_verified_full_path_present_on_ts_wth_tz = clock_timestamp() WHERE txt = '%1' AND record_deleted IS false").arg(FilePathPrepped, targetTableForFileInfo, targetSchemaForFileInfo);
                   QSqlQuery updAlreadyExistentRecinStagingDatabase;
                   if (!updAlreadyExistentRecinStagingDatabase.exec(updRecAlreadyCommand)) {
                       qDebug() << updAlreadyExistentRecinStagingDatabase.lastError().text();
                       qDebug() << updAlreadyExistentRecinStagingDatabase.lastQuery();
                       break; // Query busted
                   }
                   continue;
                }
                else {
                   qDebug().nospace() << "**** ProcessFilesTask:: new file_path:" << FilePath << ", adding.";
                }
            }

            QString parentFolderOfFile = FileInfo.dir().absolutePath(); // Parent and Grandparent folder names have details about movies and episodes.
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
            QByteArray fileData = fileObject->readAll(); // Slooooow.

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
                QString insertCommand = QString("INSERT INTO %12.%1(txt, base_name, final_extension, typ_id, file_md5_hash, file_deleted, file_size"
                                                ", file_created_on_ts, file_modified_on_ts, parent_folder_created_on_ts, parent_folder_modified_on_ts, record_deleted)"
                                                " VALUES ("
                                                // id is an identity column since this is staging and so we don't need to keep a cross-table unique-ish id. Unfortunately, the master can't link back tightly to the staging, so maybe give it a think.
                                                "/* txt */                                                '%2', " // aka full_path to the file
                                                "/* base_name */                                          '%3', " // Without the extension, which is a bit annoying sometimes
                                                "/* final_extension */                                    '%4', " // torrents have dots galore, so be careful to get the one that tells us the format
                                                "/* typ_id */                                              %5, " // replace with variable, silly!
                                                "/* file_md5_hash */                                      '%6'::bytea, " // Not cross-db compatible, the "::bytea" syntax
                                                "/* file_deleted */                                       false," // No such type as "false" in SQL Server, just bits
                                                "/* file_size */                                           %7 , " // int8 which is 64 bit. Lot of big video files
                                                "/* file_created_on_ts */                                 '%8', " // has milliseconds
                                                "/* file_modified_on_ts */                                '%9', "
                                                "/* parent_folder_created_on_ts */                        '%10', "
                                                "/* parent_folder_modified_on_t s */                      '%11',  " // These tell us whether to bother scanning again by comparing directories to directory table. huge time and thrash saver.
                                                "/* record_deleted */                                     false" // Oops. was creating 100s of dups.
                                                ")"
                                                ).arg( // Only supports string arguments
                                                   /* %1 table name */ targetTableForFileInfo
                                                 , /* %2 txt */FilePathPrepped
                                                 , /* %3 base_name */FileNamePrepped // Any other illegal characters? Check lengths first?
                                                 , /* %4 final_extension */FileNameExtension
                                                 , /* %5 typ_id */QString::number(fileTypeId)
                                                 , /* %6 file_md5_hash */fileHashAsHexString
                                                 , /* %7 file_size */QString::number(FileSize)
                                                 , /* %8 file_created_on_ts */FileCreatedOn.toString("yyyy-MM-dd HH:mm:ss.ms") // note that "ms" would be "fffffff" in sql server, 7 I think, but not all meaningful
                                                 , /* %9 file_modified_on_ts */FileModifiedOn.toString("yyyy-MM-dd HH:mm:ss.ms") // Should add a local timezone
                                                 , /* %10 parent_folder_created_on_ts */fileContainerCreatedOn.toString("yyyy-MM-dd HH:mm:ss.ms")
                                                 , /* %11 parent_folder_modified_on_ts */fileContainerModifiedOn.toString("yyyy-MM-dd HH:mm:ss.ms")
                                                 , /* %12 schema_name */ targetSchemaForFileInfo
                                                 );

                // Did it successfully add a new record to the database?

                if (!pushFilmFileInfoToDatabase.exec(insertCommand)) {
                    // No it did not add a record to the database.
                    qDebug() << pushFilmFileInfoToDatabase.lastError().text(); // Not cross-db comparable. No ANSI error codes.
                    qDebug() << pushFilmFileInfoToDatabase.lastQuery();
                    qDebug() << "**** ProcessFilesTask:: Did not add this file info!";
                    /*
                     * ERROR:  duplicate key value violates unique constraint \"files_pkey\"\nDETAIL:  Key (id)=(1) already exists.\n(23505) QPSQL: Unable to create query
                     * ERROR:  duplicate key value violates unique constraint \"ax_files_text\"\nDETAIL:  Key (text)=(D:/qBittorrent Downloads/Video/Movies/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK.mkv) already exists.\n(23505) QPSQL: Unable to create query
                     */
                    howManyFilesProcessed++; // Still failed, though, to add. But not a faily failure if it violated a unique index or constraint. This should be changed to detect difference between good errors and bad, because if the database crashes or table is locked or the sql is corrupt over it is out of domain, then that's not "processing", that's a bug.
                    //filedb.rollback(); // if there's a transaction, which on staging tables doesn't make sense
                    filedb.close();
                }
                else {

                    // Yes it did add a new record to the database (unless ON CONFLICT is present and a unique CONSTRAINT (not index) is present.

                    if (howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask:: Writing file info to files table. Completed!"; // Just show once, don't flood the zone.

                    qint64 milliSecondsProcessingThisFileTook = timeThisFileProcess.elapsed();
                    qint32 secondsProcessingThisFileTook = milliSecondsProcessingThisFileTook / 1000;
                    qDebug() << "Took" << secondsProcessingThisFileTook << "seconds to process this file.";
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

        if (timeToRunInHours > 0) {
            qDebug("**** ProcessFilesTask:: How many hours did the entire scan, hash, and insert take? %d", timeToRunInHours);
        } else if (timeToRunInMinutes > 0) {
            qDebug("**** ProcessFilesTask:: How many minutes did the entire scan, hash, and insert take? %d", timeToRunInMinutes);
        } else if (timeToRunInSeconds > 0) {
            qDebug("**** ProcessFilesTask:: How many seconds did the entire scan, hash, and insert take? %d", timeToRunInSeconds);
        } else if (timeToRunInMilliSeconds > 0) {
            qDebug("**** ProcessFilesTask:: How many milliseconds did the entire scan, hash, and insert take? %lld", timeToRunInMilliSeconds);
        } else if (timeToRunInMicroSeconds > 0) {
            qDebug("**** ProcessFilesTask:: How many microseconds did the entire scan, hash, and insert take? %lld", timeToRunInMicroSeconds);
        } else if (timeToRunInNanoSeconds > 0) {
            qDebug("**** ProcessFilesTask:: How many nanoseconds did the entire scan, hash, and insert take? %lld", timeToRunInNanoSeconds);
        }

        qDebug("**** ProcessFilesTask:: How many file's infos were read from the directory scan: %d", howManyFilesReadInfoFor);
        qDebug("**** ProcessFilesTask:: How many file's infos were limiting run to from directory scans: %d", limitedToExaminingFilesFromDirectoryScan);
        qDebug("**** ProcessFilesTask:: How many file's infos were added to database newly: %d", howManyFilesAddedToDatabaseNewly);
        qDebug("**** ProcessFilesTask:: How many file's infos were processed: %d", howManyFilesProcessed); // A bit ambiguous since the update isn't in place.

        // ------------------------------------------------------------------------------------------------------------------------------------

        qDebug("ProcessFilesTask::run():emit finished() (2)");
        emit finished();
    }

signals:
    void finished();
    // QML debugging is enabled. Only use this in a safe environment.
    // 21:29:10: D:\qt_projects\build-filmcab-Desktop_Qt_6_5_2_MinGW_64_bit-Debug\debug\filmcab.exe exited with code 0
};

#endif // PROCESSFILESTASK_H
