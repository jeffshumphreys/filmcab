QT = core \
    quick \
    widgets \
    sql


#LIBS += -lKernel32

CONFIG += c++20 cmdline

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
DEFINES += PROJECT_PATH=\"\\\"$${_PRO_FILE_PWD_}/\\\"\"
# Trying to get more detail in the stack trace. header-only is damn empty.
# Fails DEFINES += BOOST_STACKTRACE_LINK
# Fails DEFINES += BOOST_STACKTRACE_USE_BACKTRACE
# Fails DEFINES += BOOST_STACKTRACE_USE_ADDR2LINE

# Postgres was version 15 as of October 2023. Don't know why this is here, the code is working fine without it. I don't access pqlib directly.
#INCLUDEPATH += $$quote(C:/Program Files/PostgreSQL/15/include)
#LIBS += -L$$quote(C:/Program Files/PostgreSQL/15/lib)

# Boost! it has a good backtrace function
# Fails INCLUDEPATH += C:/local/boost_1_83_0
# remember to build boost: bootstrap gcc, b2 toolset=gcc link=shared threading=multi --build-type=complete stage
# ORRRR C:\local\boost_1_83_0\tools\build>bootstrap mingw,
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_filesystem-mgw13-mt-d-x64-1_83
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_stacktrace_backtrace-mgw13-mt-x64-1_83
# Fails LIBS += -LC:/local/boost_1_83_0/stage/lib libboost_system-mgw13-mt-d-x64-1_83

SOURCES += \
        main.cpp \
        processfilestask.cpp

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

#DISTFILES +=

HEADERS += \
    processfilestask.h \
    processfilestaskdata.h \
    sharedenumerations.h \
    task.h

