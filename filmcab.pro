QT = core \
    quick \
    widgets \
    sql


#LIBS += -lKernel32

CONFIG += c++20 cmdline

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Project path helps us find meta
DEFINES += PROJECT_PATH=\"\\\"$${_PRO_FILE_PWD_}/\\\"\"
# Trying to get more detail in the stack trace. header-only is damn empty.
# Fails DEFINES += BOOST_STACKTRACE_LINK
# Fails DEFINES += BOOST_STACKTRACE_USE_BACKTRACE
# Fails DEFINES += BOOST_STACKTRACE_USE_ADDR2LINE

# Postgres was version 15 as of October 2023. Don't know why this is here, the code is working fine without it. I don't access pqlib directly.
#INCLUDEPATH += $$quote(C:/Program Files/PostgreSQL/15/include)
#LIBS += -L$$quote(C:/Program Files/PostgreSQL/15/lib)

# https://github.com/dbzhang800/QtXlsxWriter for reading/writing xlsx files
#include(D:/qt_projects/qtxlsx/src/xlsx/qtxlsx.pri) Failed to compile in 6.

# https://github.com/QtExcel/QXlsx

# Boost! it has a good backtrace function
# Fails INCLUDEPATH += C:/local/boost_1_83_0
# remember to build boost: bootstrap gcc, b2 toolset=gcc link=shared threading=multi --build-type=complete stage
# ORRRR C:\local\boost_1_83_0\tools\build>bootstrap mingw,
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_filesystem-mgw13-mt-d-x64-1_83
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_stacktrace_backtrace-mgw13-mt-x64-1_83
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_system-mgw13-mt-d-x64-1_83

# QXlsx code for Application Qt project
#QXLSX_PARENTPATH=./         # current QXlsx path is . (. means curret directory)
#QXLSX_HEADERPATH=./header/  # current QXlsx header path is ./header/
#QXLSX_SOURCEPATH=./source/  # current QXlsx source path is ./source/
#include(./QXlsx.pri)

SOURCES += \
        main.cpp \
        processfilestask.cpp

# Default rules for deployment. WILL NOT MAKE an exe without these lines.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

#DISTFILES +=

HEADERS += \
    databasetaskcontrol.h \
    importexcelfilestaskdata.h \
    processfilestask.h \
    processfilestaskdata.h \
    sharedenumerations.h \
    task.h

