QT += core gui qml quick quickcontrols2 testlib
CONFIG += c++17 testcase
TARGET = omaklok_tests
TEMPLATE = app
INCLUDEPATH += ../src
HEADERS += ../src/backend.h ../src/theme.h
SOURCES += omaklok_tests.cpp ../src/backend.cpp ../src/theme.cpp
RESOURCES += ../src/resources.qrc
