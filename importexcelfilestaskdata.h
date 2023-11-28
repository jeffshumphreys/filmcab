#ifndef IMPORTEXCELFILESTASKDATA_H
#define IMPORTEXCELFILESTASKDATA_H

#include "processfilestaskdata.h"
#include "xlsxdocument.h"

class ImportExcelFilesTaskData : public ProcessFilesTaskData
{
private:
    QXlsx::Document xlsx;
public:
    void CustomFileProcessing(bool skipHash = false, QString file_path = "", qint64 database_file_id = -1) {
        qDebug() << "!!!! IMPORTEXCELFILESTASKDATA_H called";
    }
    bool loadedSpreadsheet = true;
};

#endif // IMPORTEXCELFILESTASKDATA_H
