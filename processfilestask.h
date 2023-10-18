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
///
/// \brief The ProcessFilesTask class
///
class ProcessFilesTask : public Task
{
    Q_OBJECT
public:
    // What a mess. I need to pass data, or controls in, but I don't need arguments out the kazoo.
    ProcessFilesTask(ProcessFilesTaskData &processFilesTaskData, QObject * = 0);
    // I pass in a vector of paths.
    ProcessFilesTask(ProcessFilesTasksData &processFilesTasksData, QObject * = 0);
    ProcessFilesTask(const ProcessFilesTask &);
    ProcessFilesTask &operator=(const ProcessFilesTask &);
    ~ProcessFilesTask();

private:
    QSharedDataPointer<ProcessFilesTasksData> datapackets; // Set in constructor. Creator needs to populate.

    // Right now I'm just using this to count files.
    ///
    /// \brief traverseDirectoryHierarchy
    /// \param dirname
    /// \param listOfFileTypes
    /// \param filecount each level of hierarchy adds it's count.
    /// \return the final file count.
    ///
    /*
                        .---.                               .--.                .                .   .                         .
                          |                                 |   : o            _|_               |   |  o                      |
                          |.--..-..    ._.-. .--..--. .-.   |   | .  .--..-. .-.|  .-. .--..  .  |---|  .  .-. .--..-.  .--..-.|--. .  .
                          ||  (   )\  / (.-' |   `--.(.-'   |   ; |  |  (.-'(   | (   )|   |  |  |   |  | (.-' |  (   ) |  (   |  | |  |
                          ''   `-'`-`'   `--''   `--' `--'  '--'-' `-'   `--'`-'`-'`-' '   `--|  '   '-' `-`--''   `-'`-'   `-''  `-`--|
                                                                                              ;                                        ;
                                                                                           `-'                                      `-'
    */
    int TraverseDirectoryHierarchy(ProcessFilesTaskData data, const QString &dirname, int filecount = 0, bool directoryChanged = false)
    {
        QDir dir(dirname);

        if (!dir.exists()) {
            return -1; // Only could happen on first call.  Caller needs to check for -1.
        }

        QFileInfo dirAsFile(dirname);
        QDateTime dirCreated = dirAsFile.birthTime();
        QDateTime dirModified = dirAsFile.lastModified();

        if (data.dbconnected) {
            QSqlQuery pushFileDirectoryInfoToDatabase;

            // Okay, big-ass query.  Inserts a new row, unless one already there and then it updates AND captures what id was added or updated, AND it then deletes from the return set if nothing happened.
            // Sooo, if you get a 0 row count, skip this directory.
            // If you get 1 row, SCAN this directory!

            QString upsertDirectoryTableCommand
                = QString("WITH addorupdateentry AS (\n"
                          "INSERT INTO %1.directories(\n"
                          "  txt\n"
                          ", typ_id\n"
                          ", directory_created_on_ts_wth_tz\n"
                          ", directory_modified_on_ts_wth_tz\n"
                          ", record_deleted\n"
                          ") VALUES (\n"
                          "/* txt */                                                       '%2', \n" // aka full_path to the file
                          "/* typ_id */                                                     %3 , \n" // directory for now.
                          "/* directory_created_on_ts_wth_tz */   TIMESTAMP WITH TIME ZONE '%4' "
                          "                                                   AT TIME ZONE '%5', \n" // Nuts. https://doc.qt.io/qt-6/qtime.html#toString. test with 0700, etc.
                          "/* directory_modified_on_ts_wth_tz */  TIMESTAMP WITH TIME ZONE '%6' "
                          "                                                   AT TIME ZONE '%5', \n" // These tell us whether to bother scanning again by comparing directories to directory table. huge time and thrash saver. FIX to do timezone stuff.
                          "/* record_deleted */            false \n" // default dammit! a null is bad on insert.
                          ") \n"
                          "ON CONFLICT ON CONSTRAINT directories_txt_record_deleted_key \n"
                          "DO UPDATE \n"
                          "     SET \n"
                          "  prev_directory_created_on_ts_wth_tz  = CASE WHEN directories.directory_created_on_ts_wth_tz IS DISTINCT FROM EXCLUDED.directory_created_on_ts_wth_tz THEN directories.directory_created_on_ts_wth_tz ELSE directories.prev_directory_created_on_ts_wth_tz END "
                          ", detected_change_created_dt_on        = CASE WHEN directories.directory_created_on_ts_wth_tz IS DISTINCT FROM EXCLUDED.directory_created_on_ts_wth_tz THEN now() ELSE directories.detected_change_created_dt_on END "
                          ", directory_created_on_ts_wth_tz       = EXCLUDED.directory_created_on_ts_wth_tz "

                          ", prev_directory_modified_on_ts_wth_tz = CASE WHEN directories.directory_modified_on_ts_wth_tz IS DISTINCT FROM EXCLUDED.directory_modified_on_ts_wth_tz THEN directories.directory_modified_on_ts_wth_tz ELSE directories.prev_directory_modified_on_ts_wth_tz END "
                          ", detected_change_modified_dt_on       = CASE WHEN directories.directory_modified_on_ts_wth_tz IS DISTINCT FROM EXCLUDED.directory_modified_on_ts_wth_tz THEN now() ELSE directories.detected_change_modified_dt_on END "
                          ", directory_modified_on_ts_wth_tz      = EXCLUDED.directory_modified_on_ts_wth_tz "

                          " RETURNING id, directory_created_on_ts_wth_tz, prev_directory_created_on_ts_wth_tz, detected_change_created_dt_on, directory_modified_on_ts_wth_tz, prev_directory_modified_on_ts_wth_tz, detected_change_modified_dt_on "
                          ")\n"
                          "SELECT     id, directory_created_on_ts_wth_tz, prev_directory_created_on_ts_wth_tz, detected_change_created_dt_on, directory_modified_on_ts_wth_tz, prev_directory_modified_on_ts_wth_tz, detected_change_modified_dt_on "
                          " FROM \n"
                          "    addorupdateentry "
                          "EXCEPT \n"
                          "    SELECT id, directory_created_on_ts_wth_tz, prev_directory_created_on_ts_wth_tz, detected_change_created_dt_on, directory_modified_on_ts_wth_tz, prev_directory_modified_on_ts_wth_tz, detected_change_modified_dt_on "
                          " FROM \n"
                          "   stage_for_master.directories "
                            ).arg( // Only supports string arguments
                              /* %1 schema_name */ data.targetSchema
                            , /* %2 txt */ dir.absolutePath()
                            , /* %3 typ_id */ QString::number(CommonFileTypes::directory)
                            , /* %4 directory_created_on_ts_wth_tz */ QString("%1%2").arg(dirCreated.toString("yyyy-MM-dd HH:mm:ss.zzz"), data.timeZoneOffsetAsDateFormatForFileTimestamps1) // "us" is 6 places (microseconds) Currently the CPU won't give us that.
                            , /* %5 directory_created_on_ts_wth_tz (tz) */ data.timeZoneOffsetAsDateFormatForFileTimestamps2
                            , /* %6 directory_modified_on_ts_wth_tz */QString("%1%2").arg(dirModified.toString("yyyy-MM-dd HH:mm:ss.zzz"), data.timeZoneOffsetAsDateFormatForFileTimestamps1) // Add zz? for timezone local?
                            );

            // ".noquote()" required for newlines, then I can copy the string into a SQL editor.
            qDebug().noquote() << upsertDirectoryTableCommand;

            //QRegularExpression regex(QStringLiteral("\n"));
            //QString emp("");
            //upsertDirectoryTableCommand = upsertDirectoryTableCommand.replace(regex, emp);
            //qDebug().noquote() << upsertDirectoryTableCommand;

            // Did it successfully add a new record to the database?

            if (!pushFileDirectoryInfoToDatabase.exec(upsertDirectoryTableCommand)) {
                // No it did not add a record to the database. Or update one.
                qDebug() << pushFileDirectoryInfoToDatabase.lastError().text(); // Not cross-db comparable. No ANSI error codes.
                qDebug() << pushFileDirectoryInfoToDatabase.lastQuery();
                qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Did not add this file info!";
            }
            else {
                // What was RETURNING values. Not too critical. just the fact that something changed, is enough to trigger a directory scan.
                int howManyRowsAddedOrUpdated = 0;

                while(pushFileDirectoryInfoToDatabase.next()) {
                    howManyRowsAddedOrUpdated++;
                    QDateTime directory_created_on_ts_wth_tz = pushFileDirectoryInfoToDatabase.value("directory_created_on_ts_wth_tz").toDateTime();
                    // Our first work with a result set.
                }

                if (howManyRowsAddedOrUpdated == 1) {
                    // Process files in this folder
                    directoryChanged = true;
                    // traversedown   directoryChanged = true
                }
                else if (howManyRowsAddedOrUpdated == 0) {
                    // done here.
                    return 0;
                }
                else {
                    // Huh????
                }
            }
        }

        // Somethin' changed, so process all the dirs and files in this directory, and all the way down the tree. depth

        dir.setFilter(QDir::Dirs | QDir::Files | QDir::NoSymLinks | QDir::NoDot | QDir::NoDotDot); // This argument should be passed in

        foreach (QFileInfo fileInfo, dir.entryInfoList()) {
            if (fileInfo.isDir() && fileInfo.isReadable()) {
                //qDebug() << "Is a directory:" << fileInfo.filePath() << "--" << filecount;
                filecount = TraverseDirectoryHierarchy(data, fileInfo.filePath(), filecount, directoryChanged);
        } else {
                //qDebug() << "Is NOT a directory:" << fileInfo.filePath() << "--" << filecount;
                // Suffixes are "*.mkv" style, suffix() is just "mkv", so we prepend to match.
                if (data.listOfFileTypes.contains("*." + fileInfo.suffix(), Qt::CaseSensitivity::CaseInsensitive)) {
                    filecount++; // Not working, is it counting folders instead?
                    // Examine each file and create an MD5 for it and push it to the database
                    ProcessASingleFileEntry(data, fileInfo);
                }
            }
        }
        return filecount;
    }

    /*

    88888888ba                                                                                    db             ad88888ba   88                            88                 88888888888  88  88                 88888888888
    88      "8b                                                                                  d88b           d8"     "8b  ""                            88                 88           ""  88                 88                         ,d
    88      ,8P                                                                                 d8'`8b          Y8,                                        88                 88               88                 88                         88
    88aaaaaa8P'  8b,dPPYba,   ,adPPYba,    ,adPPYba,   ,adPPYba,  ,adPPYba,  ,adPPYba,         d8'  `8b         `Y8aaaaa,    88  8b,dPPYba,    ,adPPYb,d8  88   ,adPPYba,     88aaaaa      88  88   ,adPPYba,     88aaaaa      8b,dPPYba,  MM88MMM  8b,dPPYba,  8b       d8
    88""""""'    88P'   "Y8  a8"     "8a  a8"     ""  a8P_____88  I8[    ""  I8[    ""        d8YaaaaY8b          `"""""8b,  88  88P'   `"8a  a8"    `Y88  88  a8P_____88     88"""""      88  88  a8P_____88     88"""""      88P'   `"8a   88     88P'   "Y8  `8b     d8'
    88           88          8b       d8  8b          8PP"""""""   `"Y8ba,    `"Y8ba,        d8""""""""8b               `8b  88  88       88  8b       88  88  8PP"""""""     88           88  88  8PP"""""""     88           88       88   88     88           `8b   d8'
    88           88          "8a,   ,a8"  "8a,   ,aa  "8b,   ,aa  aa    ]8I  aa    ]8I      d8'        `8b      Y8a     a8P  88  88       88  "8a,   ,d88  88  "8b,   ,aa     88           88  88  "8b,   ,aa     88           88       88   88,    88            `8b,d8'
    88           88           `"YbbdP"'    `"Ybbd8"'   `"Ybbd8"'  `"YbbdP"'  `"YbbdP"'     d8'          `8b      "Y88888P"   88  88       88   `"YbbdP"Y8  88   `"Ybbd8"'     88           88  88   `"Ybbd8"'     88888888888  88       88   "Y888  88              Y88'
                                                                                                                                               aa,    ,88                                                                                                           d8'
                                                                                                                                                "Y8bbdP"                                                                                                           d8'
    */
    LoopProcessingExitCommands ProcessASingleFileEntry(ProcessFilesTaskData data, const QFileInfo FileInfo) {
        qDebug("ProcessASingleSearchPath(ProcessFilesTaskData data)");
        QElapsedTimer timeThisFileProcess; // Time each file processing, including generating the hash, reading in the entire file, writing to the database.
        timeThisFileProcess.start();
        QSqlDatabase filedb = data.db;
        bool connected = data.dbconnected; // Caller should have connected us.

        qint64 fileTypeId = data.assumeFileTypeId;
        if (fileTypeId == 0) { fileTypeId = CommonFileTypes::file; } // A default duh, but not super useful.

        QString targetTableForFileInfo = data.tableNameToWriteNewRecordsTo;
        QString targetSchemaForFileInfo = data.targetSchema;

        QStringList listOfFileTypes = data.listOfFileTypes;
        timeThisFileProcess.restart(); // Otherwise it doesn't reset for some smart reason. Captures "elapsed()" at bottom.
        data.howManyFilesReadInfoFor++;

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
            QString checkAlreadyCommand = QString("SELECT 1 FROM %3.%2 WHERE txt = '%1' AND record_deleted is false").arg(FilePathPrepped, targetTableForFileInfo, targetSchemaForFileInfo);

            if (!checkIfFilmInfoAlreadyinStagingDatabase.exec(checkAlreadyCommand)) {
                qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastError().text();
                qDebug() << checkIfFilmInfoAlreadyinStagingDatabase.lastQuery();
                return LoopProcessingExitCommands::system_database_different_error;
            }
            int howManyRowsHadSamePath = checkIfFilmInfoAlreadyinStagingDatabase.numRowsAffected();

            if (howManyRowsHadSamePath == -1) {
                qCritical() << "Error: unable to run query that shows if path already in database. quitting.";
                return LoopProcessingExitCommands::system_database_different_error;
            }

            // error if more than one record matches full path and is not deleted, because then our vision is invalid (only one undeleted row per path is supported.)
            // Note that cross system dups could cause this violation if more than one computer involved.

            if (howManyRowsHadSamePath > 1) {
                qCritical() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) More than one undeleted record for this file path was found, which is outside universal expectations. Stopping.";
                return LoopProcessingExitCommands::system_database_different_error;
            }
            else if (howManyRowsHadSamePath == 1) {
                qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) this file_path already in files table. updating that we saw file.";
                // UPDATE table set last_verified_full_path_present_on_ts_wth_tz to now.  Then, if it goes missing, we know when it was last seen.
                QString updRecAlreadyCommand = QString("UPDATE %3.%2 SET last_verified_full_path_present_on_ts_wth_tz = clock_timestamp() WHERE txt = '%1' AND record_deleted IS false").arg(FilePathPrepped, targetTableForFileInfo, targetSchemaForFileInfo);
                QSqlQuery updAlreadyExistentRecinStagingDatabase;
                if (!updAlreadyExistentRecinStagingDatabase.exec(updRecAlreadyCommand)) {
                    qDebug() << updAlreadyExistentRecinStagingDatabase.lastError().text();
                    qDebug() << updAlreadyExistentRecinStagingDatabase.lastQuery();
                    return LoopProcessingExitCommands::system_database_different_error; // Query busted
                }
                return LoopProcessingExitCommands::completed;
            }
            else {
                qDebug().nospace() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) new file_path:" << FilePath << ", adding.";
            }
        }

        QString parentFolderOfFile = FileInfo.dir().absolutePath(); // Parent and Grandparent directories names have details about movies and episodes. Possibly greatgrannies for subs under an episode under a season under a series.
        QFileInfo FileContainerInfo = QFileInfo(parentFolderOfFile);
        QDateTime fileContainerCreatedOn = FileContainerInfo.birthTime();
        QDateTime fileContainerModifiedOn = FileContainerInfo.lastModified();

        data.howManyFilesPreppedFromDirectoryScan++;
        if (data.howManyFilesPreppedFromDirectoryScan > data.limitedToExaminingFilesFromDirectoryScan && data.limitedToExaminingFilesFromDirectoryScan != 0) {
            qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Reached imposed limit of" << data.limitedToExaminingFilesFromDirectoryScan << "for testing, stopping";
            return LoopProcessingExitCommands::stop_no_error;
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
        if (data.howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "file hash is" << fileHash.length() << "bytes";  // Need size to define in file hash column. 8?
        QByteArray fileHashAsHex = fileHash.toHex();
        QString fileHashAsHexString = QString(fileHashAsHex);
        if (data.howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) " << FileName << " : " << fileHashAsHexString;

        // Write to database. If already there, update and increment find count and date range.
        // For now, let's just add them to the files table.  We'll worry about release year, name normalization, etc.
        // If hash changed, flag it and log. size, flag it and log. dates?

        if (connected) {
            if (data.howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Starting attempt to add file info to files table...(stage_for_master.files)";
            qDebug() << data.howManyFilesPreppedFromDirectoryScan << ":" << FilePath;
            QSqlQuery pushFilmFileInfoToDatabase;
            QString insertCommand = QString("INSERT INTO %12.%1(txt, base_name, final_extension, typ_id, file_md5_hash, file_deleted, file_size"
                                            ", file_created_on_ts_wth_tz"
                                            ", file_modified_on_ts_wth_tz"
                                            ", parent_directory_created_on_ts_wth_tz"
                                            ", parent_directory_modified_on_ts_wth_tz"
                                            ", record_deleted)"
                                            " VALUES ("
                                            // id is an identity column since this is staging and so we don't need to keep a cross-table unique-ish id. Unfortunately, the master can't link back tightly to the staging, so maybe give it a think.
                                            "/* txt */                                                '%2', " // aka full_path to the file
                                            "/* base_name */                                          '%3', " // Without the extension, which is a bit annoying sometimes
                                            "/* final_extension */                                    '%4', " // torrents have dots galore, so be careful to get the one that tells us the format
                                            "/* typ_id */                                              %5, " // replace with variable, silly!
                                            "/* file_md5_hash */                                      '%6'::bytea, " // Not cross-db compatible, the "::bytea" syntax
                                            "/* file_deleted */                                       false," // No such type as "false" in SQL Server, just bits
                                            "/* file_size */                                           %7 , " // int8 which is 64 bit. Lot of big video files
                                            "/* file_created_on_ts_wth_tz */                                 '%8', " // has milliseconds
                                            "/* file_modified_on_ts_wth_tz */                                '%9', "
                                            "/* parent_directory_created_on_ts_wth_tz */                        '%10', "
                                            "/* parent_directory_modified_on_ts_wth_tz */                      '%11',  " // These tell us whether to bother scanning again by comparing directories to directory table. huge time and thrash saver.
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
                                            , /* %8 file_created_on_ts_wth_tz */FileCreatedOn.toString("yyyy-MM-dd HH:mm:ss.zzz") // note that "ms" would be "fffffff" in sql server, 7 I think, but not all meaningful
                                            , /* %9 file_modified_on_ts_wth_tz */FileModifiedOn.toString("yyyy-MM-dd HH:mm:ss.zzz") // Should add a local timezone
                                            , /* %10 parent_directory_created_on_ts_wth_tz */fileContainerCreatedOn.toString("yyyy-MM-dd HH:mm:ss.zzz")
                                            , /* %11 parent_directory_modified_on_ts_wth_tz */fileContainerModifiedOn.toString("yyyy-MM-dd HH:mm:ss.zzz")
                                            , /* %12 schema_name */ targetSchemaForFileInfo
                                            );

            // Did it successfully add a new record to the database?

            if (!pushFilmFileInfoToDatabase.exec(insertCommand)) {
                // No it did not add a record to the database.
                qDebug() << pushFilmFileInfoToDatabase.lastError().text(); // Not cross-db comparable. No ANSI error codes.
                qDebug() << pushFilmFileInfoToDatabase.lastQuery();
                qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Did not add this file info!";
                /*
                     * ERROR:  duplicate key value violates unique constraint \"files_pkey\"\nDETAIL:  Key (id)=(1) already exists.\n(23505) QPSQL: Unable to create query
                     * ERROR:  duplicate key value violates unique constraint \"ax_files_text\"\nDETAIL:  Key (text)=(D:/qBittorrent Downloads/Video/Movies/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK.mkv) already exists.\n(23505) QPSQL: Unable to create query
                     */
                data.howManyFilesProcessed++; // Still failed, though, to add. But not a faily failure if it violated a unique index or constraint. This should be changed to detect difference between good errors and bad, because if the database crashes or table is locked or the sql is corrupt over it is out of domain, then that's not "processing", that's a bug.
                //filedb.rollback(); // if there's a transaction, which on staging tables doesn't make sense
                filedb.close();
                return LoopProcessingExitCommands::system_database_different_error;
            }
            else {

                // Yes it did add a new record to the database (unless ON CONFLICT is present and a unique CONSTRAINT (not index) is present.

                if (data.howManyFilesPreppedFromDirectoryScan == 1) qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Writing file info to files table. Completed!"; // Just show once, don't flood the zone.

                qint64 milliSecondsProcessingThisFileTook = timeThisFileProcess.elapsed();
                qint32 secondsProcessingThisFileTook = milliSecondsProcessingThisFileTook / 1000;
                qDebug() << "**** ProcessFilesTask::ProcessASingleSearchPath(data) Took" << secondsProcessingThisFileTook << "seconds to process this file.";
                data.howManyFilesAddedToDatabaseNewly++; // Not updated, which is not an error, but without the ON CONFLICT working we can't trap exactly.
                data.howManyFilesProcessed++;
                data.howManyFilesProcessedSuccessfully++; // Have to update this if I get ON CONFLICT and updates working, as that's processing.
            }
            return LoopProcessingExitCommands::completed;
        }
        return LoopProcessingExitCommands::no_op; // wasn't connected, so didn't do anything.
    }

public slots:

    // Called from main() to start the async task.

    void run()
    {
        qDebug("ProcessFilesTask::run()");
        QElapsedTimer timer;
        timer.start();

        // Loop through the data packets, where mostly it's just a different search path.  I want it sequential; scanning multiple paths async would blow chunks.

        foreach (ProcessFilesTaskData procFilesTaskDataPacket, datapackets->processFilesTasksData) {
            QString searchPath = procFilesTaskDataPacket.searchPath;
            qDebug() << "ProcessFilesTask::run(): Processing a single data packet: searching " << searchPath;
            TraverseDirectoryHierarchy(procFilesTaskDataPacket, searchPath);
            qDebug("ProcessFilesTask::run(): Processing a single data packet finished");
            qDebug("**** ProcessFilesTask::run(): How many file's infos were read from the directory scan: %d", procFilesTaskDataPacket.howManyFilesReadInfoFor);
            qDebug("**** ProcessFilesTask::run(): How many file's infos were limiting run to from directory scans: %d", procFilesTaskDataPacket.limitedToExaminingFilesFromDirectoryScan);
            qDebug("**** ProcessFilesTask::run(): How many file's infos were added to database newly: %d", procFilesTaskDataPacket.howManyFilesAddedToDatabaseNewly);
            qDebug("**** ProcessFilesTask::run(): How many file's infos were processed: %d", procFilesTaskDataPacket.howManyFilesProcessed); // A bit ambiguous since the update isn't in place.
        }

        qint64 timeToRunInNanoSeconds  = timer.nsecsElapsed(); // Ya know, jeff, ya could use elapsed() for milliseconds.
        qint64 timeToRunInMicroSeconds = timeToRunInNanoSeconds / 1000;
        qint64 timeToRunInMilliSeconds = timeToRunInMicroSeconds / 1000;
        qint32 timeToRunInSeconds      = timeToRunInMilliSeconds / 1000;
        qint32 timeToRunInMinutes      = timeToRunInSeconds / 60;
        qint16 timeToRunInHours        = timeToRunInMinutes / 60;

        if (timeToRunInHours > 0) {
            qDebug("**** ProcessFilesTask::run():  How many hours did the entire scan, hash, and insert take? %d", timeToRunInHours);
        } else if (timeToRunInMinutes > 0) {
            qDebug("**** ProcessFilesTask::run():  How many minutes did the entire scan, hash, and insert take? %d", timeToRunInMinutes);
        } else if (timeToRunInSeconds > 0) {
            qDebug("**** ProcessFilesTask::run():  How many seconds did the entire scan, hash, and insert take? %d", timeToRunInSeconds);
        } else if (timeToRunInMilliSeconds > 0) {
            qDebug("**** ProcessFilesTask::run():  How many milliseconds did the entire scan, hash, and insert take? %lld", timeToRunInMilliSeconds);
        } else if (timeToRunInMicroSeconds > 0) {
            qDebug("**** ProcessFilesTask::run():  How many microseconds did the entire scan, hash, and insert take? %lld", timeToRunInMicroSeconds);
        } else if (timeToRunInNanoSeconds > 0) {
            qDebug("**** ProcessFilesTask::run():  How many nanoseconds did the entire scan, hash, and insert take? %lld", timeToRunInNanoSeconds);
        }


        // ------------------------------------------------------------------------------------------------------------------------------------

        qDebug("ProcessFilesTask::ProcessASingleSearchPath(data)run():emit finished() (2)");
        emit finished();
    }

signals:
    void finished();
    // QML debugging is enabled. Only use this in a safe environment.
    // 21:29:10: D:\qt_projects\build-filmcab-Desktop_Qt_6_5_2_MinGW_64_bit-Debug\debug\filmcab.exe exited with code 0
};

#endif // PROCESSFILESTASK_H
