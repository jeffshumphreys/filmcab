#ifndef PROCESSFILESTASKDATA_H
#define PROCESSFILESTASKDATA_H

#include "qshareddata.h" // Maybe if we keep this untied to processfilestask, it will reduce compiles?
#include "taskcontrol.h"
#include "databasetaskcontrol.h"
#include "filetaskcontrol.h"

#include <QtCore> // QStringList

class ProcessFilesTaskData : public DatabaseTaskControl, public FileTaskControl, public TaskControl
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
//    int howManyFilesAddedToDatabaseNewly         = 0;

    // file controls


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
