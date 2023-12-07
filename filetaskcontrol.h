#ifndef FILETASKCONTROL_H
#define FILETASKCONTROL_H

#include <QDir>
#include <QDirIterator>

#include "sharedenumerations.h"

// This is part of a multiple inheritance subclass into the ProcessFilesTaskData.

class FileTaskControl {
public:
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

};

#endif // FILETASKCONTROL_H
