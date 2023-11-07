#ifndef PROCESSFILESTASKDATA_H
#define PROCESSFILESTASKDATA_H

#include "qshareddata.h" // Maybe if we keep this untied to processfilestask, it will reduce compiles?
#include "qsqldatabase.h"
#include "sharedenumerations.h"
#include "databasetaskcontrol.h"

#include <QtCore> // QStringList
#include <QDir>
#include <QDirIterator>

class ProcessFilesTaskData : public DatabaseTaskControl
{
public:
    ProcessFilesTaskData() {
        // Won't work elsewhere, or 1/2 hr timezones. I default to negative sign.
        // https://www.postgresql.org/docs/11/functions-datetime.html#FUNCTIONS-DATETIME-ZONECONVERT

        int localTimeTZOffsetHours = QTimeZone::systemTimeZone().offsetData(QDateTime::currentDateTime()).daylightTimeOffset / 600; //.Local.BaseUtcOffset.Hours;

        // This is awful, but in Postgres testing, only the following worked "SELECT TIMESTAMP WITH TIME ZONE '2023-10-12 18:39:35.691-0600' AT TIME ZONE '+06:00';"

        // test support for + offsets.  Ideally we should store UTC. :(
        QString p1=QString::number(localTimeTZOffsetHours).rightJustified(2, '0');
        QString p2="00";
        QString localTimeZoneOffsetAsDateFormat1 = QString("-%1%2").arg(p1, p2); // Whew! It's suggested not to use sprintf, so........
        timeZoneOffsetAsDateFormatForFileTimestamps1 = localTimeZoneOffsetAsDateFormat1;
        QString localTimeZoneOffsetAsDateFormat2 = QString("+%1:00").arg(QString::number(localTimeTZOffsetHours).rightJustified(2, '0')); // Whew! It's suggested not to use sprintf, so........
        timeZoneOffsetAsDateFormatForFileTimestamps2 = localTimeZoneOffsetAsDateFormat2;
        formatToPullStringFromQStringIntoPostgresTimestamptzConstant = "";
    }

    //ProcessFilesTaskData(ProcessFilesTaskData& copyFromThis);

public:

    // Data controls

    //QSqlDatabase db; // Must be set by caller or any reading/writing to db will be skipped.

    //bool triedToConnect = false;

    //bool dbconnected = false;

//    QString tableNameToWriteNewRecordsTo; // ex: files

//    QString targetSchema = ""; // stage_for_master, for instance. Eventually, master.

//    IdentityMethod identityMethod = IdentityMethod::reset_if_truncating;

//    PreProcessTable preProcessTargetTable = PreProcessTable::leave_as_is; // Should capture counts

//    AddRowsMethod addRowsMethod = AddRowsMethod::ignore_if_logical_key_collision;

//    int howManyFilesAddedToDatabaseNewly         = 0;

    // file controls

    FileChangeDetectionClass::FileChangeDetections fileChangeDetection
        = FileChangeDetectionClass::FileChangeDetection::check_dir_mod_dt_against_directory_recrded_mod_dt |
          FileChangeDetectionClass::FileChangeDetection::scan_dir_if_mod_dt_newer; // Only if entry is dir.

    qint64 assumeFileTypeId; // probably should use long long. We "assume" because we're not really checking the file to validate. Lots of srt files get typed as movies, for example.
    QString file_flow_state_enum_str = "unknown"; // MUST exist in filmcab.public.file_flow_state_enum values. One of the annoyances of syncronized database-code.
    QString searchPath = ""; // Only one at a time for now.

    QStringList listOfFileTypes = {"*.*"}; // defaults to all; you should override this.

    QDir::Filters directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files; // Default to not catching directories. I'll change that.

    QDirIterator::IteratorFlags directoryIteratorFlags = QDirIterator::Subdirectories;

    QString timeZoneOffsetAsDateFormatForFileTimestamps1; // defaulted in constructor.  You must override if you are say pulling from some online cloud file system with utc, or some other datetime.
    QString timeZoneOffsetAsDateFormatForFileTimestamps2; // defaulted in constructor.  You must override if you are say pulling from some online cloud file system with utc, or some other datetime.
    QString formatToPullStringFromQStringIntoPostgresTimestamptzConstant; // huh?

    int howManyFilesReadInfoFor                  = 0; // Now that I'm skipping files, I like to know how many were grabbed
    int howManyFilesPreppedFromDirectoryScan     = 0; // ambiguous name
    int howManyFilesProcessed                    = 0; // including failures
    int howManyFilesProcessedSuccessfully        = 0; // Not necessarily added. What does "Successfully" mean?  Added? Skipped? Serious failures tend to stop the program.
    int howManyFilesDetectedAsBothInDbAndInFS    = 0;
    int limitedToExaminingFilesFromDirectoryScan = 0; // 0 means don't apply limit

    int howManyDirectoriesChanged                = 0; // And therefore scanned and drilled
    int howManyNewDirectories                    = 0; // Added to directories table and scanned
    int howManyDirectoriesUnchanged              = 0; // And therefore skipped
    int howManyDirectoriesRecreated              = 0; // An odd thing if the created date changes.
    int howManyDirectoriesTested                 = 0;

    qint64 filesBatchRunsLog_id                    = 0;
};


class ProcessFilesTasksData  : public QSharedData
{
public:
    ProcessFilesTasksData() {

    }
    ProcessFilesTasksData(ProcessFilesTaskData& p) {
        processFilesTasksData = {p};
    }

public:
    QVector<ProcessFilesTaskData> processFilesTasksData;

};

#endif // PROCESSFILESTASKDATA_H
