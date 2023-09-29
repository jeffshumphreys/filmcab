#ifndef PROCESSFILESTASKDATA_H
#define PROCESSFILESTASKDATA_H

#include "qshareddata.h" // Maybe if we keep this untied to processfilestask, it will reduce compiles?
#include "qsqldatabase.h"

class ProcessFilesTaskData : public QSharedData
{
public:
    ProcessFilesTaskData() {

    }

public:
    qint64 assumeFileTypeId; // probably should use long long. We "assume" because we're not really checking the file to validate. Lots of srt files get typed as movies, for example.
    qint64 searchPathId;
    QSqlDatabase db; // Must be set by caller or any reading/writing to db will be skipped.
};

#endif // PROCESSFILESTASKDATA_H
