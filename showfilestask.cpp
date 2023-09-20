#include "showfilestask.h"
#include <QDebug>

class ShowFilesTaskData : public QSharedData
{
public:

};

ShowFilesTask::ShowFilesTask(QObject *parent)
    : Task{parent}, data(new ShowFilesTaskData)
{
    qDebug("ShowFilesTask::ShowFilesTask(QObject *parent)");
}

ShowFilesTask::ShowFilesTask(const ShowFilesTask &rhs)
    : data{rhs.data}
{
    qDebug("ShowFilesTask::ShowFilesTask(const ShowFilesTask &rhs): data{rhs.data}");
}

ShowFilesTask &ShowFilesTask::operator=(const ShowFilesTask &rhs)
{
    qDebug("ShowFilesTask &ShowFilesTask::operator=(const ShowFilesTask &rhs)");
    if (this != &rhs)
        data.operator=(rhs.data);
    return *this;
}

ShowFilesTask::~ShowFilesTask()
{

}
