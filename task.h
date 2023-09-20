#ifndef TASK_H
#define TASK_H

#include <QtCore>

class Task : public QObject
{
    Q_OBJECT
    // The Q_OBJECT macro inside the private section of the class declaration is used to enable meta-object features, such as dynamic properties, signals, and slots.
public:
    Task(QObject *parent = 0) : QObject(parent) {
            // Constructor defined here.  Q_OBJECT causes qmake to run moc and generate task.cpp(???)
            qDebug("Task(QObject *parent = 0) : QObject(parent)");
        };

public slots:
    void run()
    {
        // Do processing here
        qDebug("Task::run()");
        //emit finished();
    }

signals:
//    void finished();
};

#endif // TASK_H
