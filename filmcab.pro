QT = core \
    quick \
    widgets \
    sql

CONFIG += c++20 cmdline

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Postgres was version 15 as of October 2023
#INCLUDEPATH += $$quote(C:/Program Files/PostgreSQL/15/include)
#LIBS += -L$$quote(C:/Program Files/PostgreSQL/15/lib)

SOURCES += \
        main.cpp \
        processfilestask.cpp

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES +=

HEADERS += \
    processfilestask.h \
    task.h

