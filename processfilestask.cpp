#include "processfilestask.h"
#include <QDebug>

class ProcessFilesTaskData : public QSharedData
{
public:

};

ProcessFilesTask::ProcessFilesTask(QObject *parent)
    : Task{parent}, data(new ProcessFilesTaskData)
{
    qDebug("ProcessFilesTask::ProcessFilesTask(QObject *parent)");
}

ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs)
    : data{rhs.data}
{
    qDebug("ProcessFilesTask::ProcessFilesTask(const ProcessFilesTask &rhs): data{rhs.data}");
}

ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)
{
    qDebug("ProcessFilesTask &ProcessFilesTask::operator=(const ProcessFilesTask &rhs)");
    if (this != &rhs)
        data.operator=(rhs.data);
    return *this;
}

ProcessFilesTask::~ProcessFilesTask()
{

}
