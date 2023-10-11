#ifndef PROCESSFILESTASKDATA_H
#define PROCESSFILESTASKDATA_H

#include "qshareddata.h" // Maybe if we keep this untied to processfilestask, it will reduce compiles?
#include "qsqldatabase.h"
#include "sharedenumerations.h"

#include <QtCore> // QStringList
#include <QDir>
#include <QDirIterator>

class ProcessFilesTaskData : public QSharedData
{
public:
    ProcessFilesTaskData() {

    }

public:
    qint64 assumeFileTypeId; // probably should use long long. We "assume" because we're not really checking the file to validate. Lots of srt files get typed as movies, for example.
    QSqlDatabase db; // Must be set by caller or any reading/writing to db will be skipped.

    bool triedToConnect = false;

    bool dbconnected = false;

    QString tableNameToWriteNewRecordsTo;
    bool skip_db_writes_even_if_connected = false;
    QString searchPath = ""; // Only one at a time for now.

    QStringList listOfFileTypes = {"*.*"};

    QDir::Filters directoryIteratorFilters = QDir::NoDotAndDotDot|QDir::Files;

    QDirIterator::IteratorFlags directoryIteratorFlags = QDirIterator::Subdirectories;

    TargetLayer targetLayer = TargetLayer::stage_for_master;

    IdentityMethod identityMethod = IdentityMethod::reset_if_truncating;

    PreProcessTable preProcessTargetTable = PreProcessTable::leave_as_is; // Should capture counts

    AddRowsMethod addRowsMethod = AddRowsMethod::ignore_if_logical_key_collision;

    FileChangeDetectionClass::FileChangeDetections fileChangeDetection
        = FileChangeDetectionClass::FileChangeDetection::check_dir_mod_dt_against_directory_recrded_mod_dt |
          FileChangeDetectionClass::FileChangeDetection::scan_dir_if_mod_dt_newer; // Only if entry is dir.
};

#endif // PROCESSFILESTASKDATA_H
