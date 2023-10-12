#include "processfilestaskdata.h"
#include "processfilestask.h"

#include <QDebug>

// WARNING: Newbe.  I want the constructor forced to have some data args, I think, maybe?? So I switched the arguments around

ProcessFilesTask::ProcessFilesTask(ProcessFilesTaskData &processFilesTaskData, QObject *parent)
    : Task{parent}
{
    datapackets = QSharedDataPointer<ProcessFilesTasksData>(new ProcessFilesTasksData); // Empty?
    datapackets->processFilesTasksData = {processFilesTaskData};
}


ProcessFilesTask::ProcessFilesTask(ProcessFilesTasksData &processFilesTasksData, QObject *parent)
    : Task{parent}
{
    datapackets = QSharedDataPointer<ProcessFilesTasksData>(new ProcessFilesTasksData); // Empty?
    datapackets->processFilesTasksData = processFilesTasksData.processFilesTasksData;
}

ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs) // Creates a new object with the data of the other
    : datapackets{rhs.datapackets}
{
    qDebug("ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs): data{rhs.data}");
}

ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs) // Assigns the data of another object to this object
{
    qDebug("ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)");
    if (this != &rhs)
        datapackets.operator=(rhs.datapackets);
    return *this;
}

ProcessFilesTask::~ProcessFilesTask()
{

}
