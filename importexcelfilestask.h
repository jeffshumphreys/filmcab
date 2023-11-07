#ifndef IMPORTEXCELFILESTASK_H
#define IMPORTEXCELFILESTASK_H

#include "importexcelfilestaskdata.h"
#include "processfilestask.h"

class ImportExcelFilesTask : public ProcessFilesTask
{
    Q_OBJECT
public:
    ImportExcelFilesTask(ImportExcelFilesTaskData &importExcelFilesTaskData, QObject * = 0);
};

#endif // IMPORTEXCELFILESTASK_H
