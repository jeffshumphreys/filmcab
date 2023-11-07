#ifndef DATABASETASKCONTROL_H
#define DATABASETASKCONTROL_H

#include "qsqldatabase.h"
#include "sharedenumerations.h"

class DatabaseTaskControl {
public:
    QSqlDatabase db; // Must be set by caller or any reading/writing to db will be skipped.

    bool triedToConnect = false;

    bool dbconnected = false;

    QString tableNameToWriteNewRecordsTo; // ex: files

    QString targetSchema = ""; // stage_for_master, for instance. Eventually, master.

    IdentityMethod identityMethod = IdentityMethod::reset_if_truncating;

    PreProcessTable preProcessTargetTable = PreProcessTable::leave_as_is; // Should capture counts

    AddRowsMethod addRowsMethod = AddRowsMethod::ignore_if_logical_key_collision;

    int howManyFilesAddedToDatabaseNewly         = 0;
};

#endif // DATABASETASKCONTROL_H
