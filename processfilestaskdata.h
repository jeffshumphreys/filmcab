#ifndef PROCESSFILESTASKDATA_H
#define PROCESSFILESTASKDATA_H

#include "qshareddata.h" // Maybe if we keep this untied to processfilestask, it will reduce compiles?
class ProcessFilesTaskData : public QSharedData
{
public:
    ProcessFilesTaskData() {

    }

public:
    int assumeFileTypeId;
};

#endif // PROCESSFILESTASKDATA_H
