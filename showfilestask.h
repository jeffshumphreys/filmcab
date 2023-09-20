#ifndef SHOWFILESTASK_H
#define SHOWFILESTASK_H

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

class ShowFilesTaskData;

class ShowFilesTask : public Task
{
    Q_OBJECT
    QML_ELEMENT
public:
    ShowFilesTask(QObject * = 0);

    ShowFilesTask(const ShowFilesTask &);
    ShowFilesTask &operator=(const ShowFilesTask &);
    ~ShowFilesTask();

private:
    QSharedDataPointer<ShowFilesTaskData> data;

public slots:
    void run()
    {
        qDebug("ShowFilesTask::run()");

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

        int howManyMovieFilesFound = 0;

        QString movieFilesBaseDirectory = "D:/qBittorrent Downloads/Video/Movies";
        qDebug() << "**** ShowFilesTask:: Scanning " << movieFilesBaseDirectory;
        QDirIterator movieFileDirectories(movieFilesBaseDirectory, {"*.mkv", "*.avi", "*.mp4", "*.mpg", "*.wmv", "*.srt", "*.sub", "*.idx" }, QDir::NoDotAndDotDot|QDir::Files, QDirIterator::Subdirectories);

        // Examine each movie file and create an MD5 for it

        while (movieFileDirectories.hasNext()) {
            QFileInfo movieFileInfo = movieFileDirectories.nextFileInfo(); howManyMovieFilesFound++;
            if (howManyMovieFilesFound > 1) {
                break;
            }

            QString movieFileName = movieFileInfo.fileName();
            //qDebug() << "**** ShowFilesTask:: name=" << movieFileName;

            QString movieFilePath = movieFileInfo.filePath();
            //qDebug() << "**** ShowFilesTask::  path=" << movieFilePath;

            int movieFileSize = movieFileInfo.size();
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
            qDebug() << "**** ShowFilesTask:: " << movieFileName << " : " << fileHashAsHexString;

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
                            if (partPositionInName == 0) appearsToHaveReleaseYearInName/= (3.0 / (partPositionInName + 1.0)); // Like movies starting with "1984" released in 1956
                            // "2001: A Space Odyssey"  released in 1968
                            // Tamala 2010: A Punk Cat in Space" was released in 2002
                        }
                    }
                    // is only one year present?
                    // if surrounded by brackets
                }

                partPositionInName++;
            }

            // Write to database. If already there, update and increment find count and date range.
            // If hash changed, flag it and log. size, flag it and log. dates?

        }
//        moviefilesdir.setNameFilters(QStringList() << "*.*");
//        moviefilesdir.setFilter(QDir::Files);
//        QStringList moviefilenames = moviefilesdir.entryList(); // entryInfoList
//        int howmanyfiles = moviefilenames.count();
//        qDebug("**** ShowFilesTask:: Found %d file(s) in %s", howmanyfiles, movieFilesBaseDirectory.toStdString().c_str());
//        QString filenamesfound = moviefilenames.join(", ");
        qDebug("**** ShowFilesTask:: How many files read: %d", howManyMovieFilesFound);

        // ------------------------------------------------------------------------------------------------------------------------------------
        qDebug("ShowFilesTask::run():emit finished()");
        emit finished();
    }

signals:
    void finished();

};

#endif // SHOWFILESTASK_H
