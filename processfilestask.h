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
//#include <QtMultimedia/QtMultimedia> // Will use eventually
#include <QSqlDatabase>  // Requires "sql" added to .pro file
#include <QSqlError> // Required to not get "Calling 'lastError' with incomplete return type 'QSqlError'" on lastError
#include <QSqlQueryModel>
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

public slots:
    void run()
    {
        qDebug("ProcessFilesTask::run()");

        // Connect to db so we can push the files found to a persistent store.

        QSqlDatabase moviedb = QSqlDatabase::addDatabase("QPSQL"); /* Had to add the "sql" line to the .pro file in string "QT =
            core \
            quick \
            widgets \
            sql
        */

        moviedb.setHostName("localhost");
        moviedb.setPort(5432);
        moviedb.setDatabaseName("genericdatabase");
        moviedb.setUserName("postgres");
        moviedb.setPassword("postgres");

        // TODO: Record that we successfully connected.  When it fails, we can recognize that we have successfully connected for n years or something, so it's something that had been fine.

        qDebug() << "Attempting to connect to:" << moviedb.hostName() << moviedb.port() << moviedb.userName() << moviedb.password();

        bool connected = moviedb.open();

        if(!connected) {
            auto connectionError = moviedb.lastError();
            qCritical() << "Error on attempting to open database:" << connectionError.text();
        }
        else {
            qDebug() << "Connected successfully!";
            //QSqlQuery q(db);
            //q.exec("SET NAMES latin1");
        }

        // Start processing the files I have, movies and TV, torrented files, cleaned up, and backup files, and eventually cleaned and reduced bit width files.
        // On primary is to grab create and modify dates, sizes, and an MD5 hash for matching when names change.

        int howManyMovieFilesFound = 0; // ambiguous name
        int howManyMovieFilesProcessed = 0; // including failures
        int howManyMovieFilesProcessedSuccessfully = 0;
        int howManyMovieFilesAddedToDatabaseNewly = 0;
        int howManyMovieFilesFoundInSearchPath = 0; // Argh! no "count" attribute!

        QString movieFilesBaseDirectory = "D:/qBittorrent Downloads/Video/Movies";
        qDebug() << "**** ProcessFilesTask:: Scanning " << movieFilesBaseDirectory;

        // This is slow for testing, and in production we want this to only look at directories that have changed since last scan.

        QDirIterator movieFileDirectories(movieFilesBaseDirectory, {"*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx", "*.vob" }, QDir::NoDotAndDotDot|QDir::Files, QDirIterator::Subdirectories);

        // Examine each movie file and create an MD5 for it

        while (movieFileDirectories.hasNext()) {
            QFileInfo movieFileInfo = movieFileDirectories.nextFileInfo(); howManyMovieFilesFound++;
            if (howManyMovieFilesFound > 1) {
                break;
            }

            QString movieFileNameExtension = movieFileInfo.suffix(); // Just the last suffix

            //qDebug() << "**** ProcessFilesTask:: name=" << movieFileName;

            QString movieFilePath = movieFileInfo.filePath();
            //qDebug() << "**** ProcessFilesTask::  path=" << movieFilePath;

            QString movieFileName = movieFileInfo.completeBaseName(); // All the dots

            qint64 movieFileSize = movieFileInfo.size();
            QDateTime movieFileCreatedOn = movieFileInfo.birthTime();
            QDateTime movieFileModifiedOn = movieFileInfo.lastModified();

            QFile * fileObject = new QFile(movieFilePath);
            fileObject->open(QIODevice::ReadOnly);  // Note that torrent files will not be still downloading, only the final completed file is in this folder.
            QByteArray fileData = fileObject->readAll();

            // Construct a unique hash identifier for compare

            QByteArray fileHash = QCryptographicHash::hash(fileData, QCryptographicHash::Md5);
            qDebug() << "file hash is" << fileHash.length() << "bytes";  // Need size to define in file hash column. 8?
            QByteArray fileHashAsHex = fileHash.toHex();
            QString fileHashAsHexString = QString(fileHashAsHex);
            qDebug() << "**** ProcessFilesTask:: " << movieFileName << " : " << fileHashAsHexString;

            // year found from name

            int appearsToBeReleaseYearInName;

            // likelihood of it being a year for a movie release

            double appearsToHaveReleaseYearInName = 0.0;

            // Break out parts of dot separated name, which is the common way files are kept as torrents, not spaces

            int partPositionInName = 0;
            int howManyPossibleYearsFound = 0;  // More than one usually means one is part of the name, or some other indication.

            QStringList movieFileNameDottedParts = movieFileName.split('.');
            for (const auto& dottedPart : movieFileNameDottedParts) {
                // Always file labels are 4 part years for release due to 19-- and 20--
                if (dottedPart.length() == 4) {
                    appearsToHaveReleaseYearInName = 0.1;
                    bool isDottedPartAPositiveInteger;

                    // avoid negatives or decimals
                    int dottedPartAsPositiveInteger = dottedPart.toUInt(&isDottedPartAPositiveInteger);
                    if (dottedPartAsPositiveInteger) {
                        appearsToHaveReleaseYearInName = 0.4;

                        // movies can only be "released" within an actual technical region

                        if (dottedPartAsPositiveInteger >= 1890 && isDottedPartAPositiveInteger <= QDate::currentDate().year()) {

                            // A file of a movie wouldn't have a future date in it's name.  In IMDB there are upcoming releases.

                            appearsToHaveReleaseYearInName = 0.7; // High probability, but not sure if it's release year or part of the name

                            // If first part of name, very unlikely

                            if (partPositionInName == 0) appearsToHaveReleaseYearInName/= (3.0 / (partPositionInName + 1.0)); // Like movies starting with "1984" released in 1956
                            // "2001: A Space Odyssey"  released in 1968
                            // Tamala 2010: A Punk Cat in Space" was released in 2002 So detect trailing ":" and trailing regular word strings
                        }
                    }
                    // is only one year present? ++appearsToHaveReleaseYearInName
                    // if surrounded by brackets, ++appearsToHaveReleaseYearInName
                }

                partPositionInName++;
            }

            // Write to database. If already there, update and increment find count and date range.
            // For now, let's just add them to the files table.  We'll worry about release year, name normalization, etc.
            // If hash changed, flag it and log. size, flag it and log. dates?

            qDebug() << "**** ProcessFilesTask:: Starting attempt to add file info to files table...";

            QSqlQuery pushFilmFileInfoToDatabase;
            QString insertCommand = QString("INSERT INTO stage_for_master.files(text, base_name, final_extension, type_id, record_version_for_same_name_file, file_md5_hash, file_deleted, file_size, file_created_on_ts, file_modified_on_ts)"
                                            " VALUES ("
                                            /* id is an identity column since this is staging */
                                            "/* text */                                               '%1', " /* aka full_path */
                                            "/* base_name */                                          '%2', "
                                            "/* final_extension */                                    '%3', "
                                            "/* type_id: Downloaded Torrent File */ 8, "
                                            "/* This version (guess) and update should fix if trigger ever hit # */ 1, "
                                            "/* file_md5_hash */                                      '%4'::bytea, "
                                            "/* file_deleted */                     false,"
                                            "/* file_size */                                           %5,"
                                            "/* file_created_on_ts */                                 '%6',"
                                            "/* file_modified_on_ts */                                '%7'"
                                            ")"
                                            " ON CONFLICT ON CONSTRAINT files_text_version DO NOTHING"
                                            /* ON CONFLICT....*/ /* No unique constraint exactly since I'm holding deleted files in here */
                                            ).arg(movieFilePath, movieFileName, movieFileNameExtension, fileHashAsHexString, QString::number(movieFileSize)
                                             , movieFileCreatedOn.toString("yyyy-MM-dd HH:mm:ss.ms") /* note that "ms" would be "fffffff" in sql server */
                                             , movieFileModifiedOn.toString("yyyy-MM-dd HH:mm:ss.ms"));

            // Did it successfully add a new record to the database?

            if (!pushFilmFileInfoToDatabase.exec(insertCommand)) {
                qDebug() << pushFilmFileInfoToDatabase.lastError().text();
                qDebug() << pushFilmFileInfoToDatabase.lastQuery();
                qDebug() << "**** ProcessFilesTask:: Did not add this file info!";
                /*
                 * ERROR:  duplicate key value violates unique constraint \"files_pkey\"\nDETAIL:  Key (id)=(1) already exists.\n(23505) QPSQL: Unable to create query
                 * ERROR:  duplicate key value violates unique constraint \"ax_files_text\"\nDETAIL:  Key (text)=(D:/qBittorrent Downloads/Video/Movies/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK.mkv) already exists.\n(23505) QPSQL: Unable to create query
                 */
                howManyMovieFilesProcessed++;
            }
            else {
                qDebug() << "**** ProcessFilesTask:: Writing file info to files table. Completed!";
                howManyMovieFilesAddedToDatabaseNewly++; // Not updated, which is not an error, but without the ON CONFLICT working we can't trap exactly.
                howManyMovieFilesProcessed++;
                howManyMovieFilesProcessedSuccessfully++; // Have to update this if I get ON CONFLICT and updates working, as that's processing.
            }

        }

//        moviefilesdir.setNameFilters(QStringList() << "*.*");
//        moviefilesdir.setFilter(QDir::Files);
//        QStringList moviefilenames = moviefilesdir.entryList(); // entryInfoList
//        QString filenamesfound = moviefilenames.join(", ");
        qDebug("**** ProcessFilesTask:: How many file's infos were added to database newly: %d", howManyMovieFilesAddedToDatabaseNewly);
        qDebug("**** ProcessFilesTask:: How many file's infos were processed: %d", howManyMovieFilesProcessed); // A bit ambiguous since the update isn't in place.

        // ------------------------------------------------------------------------------------------------------------------------------------
        qDebug("ProcessFilesTask::run():emit finished()");
        emit finished();
    }

signals:
    void finished();

};

#endif // PROCESSFILESTASK_H
