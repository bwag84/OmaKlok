#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>
#include <QIcon>
#include <QLocale>
#include "backend.h"
#include "theme.h"
int main(int argc, char **argv) {
    QGuiApplication app(argc,argv);
    app.setOrganizationName("OmaKlok"); app.setApplicationName("omaklok");
    app.setApplicationVersion("0.1.0"); app.setDesktopFileName("omaklok");
    app.setWindowIcon(QIcon(":/omaklok.svg"));
    QLocale::setDefault(QLocale("nl_NL"));
    QQuickStyle::setStyle("Material");
    bool preview=app.arguments().contains("--screenshot");
    Backend backend(nullptr,!preview);
    if(preview) backend.setMode(0);
    Theme theme(preview ? "/tmp/omaklok-preview-theme" : QString());
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend",&backend);
    engine.rootContext()->setContextProperty("theme",&theme);
    engine.load(QUrl("qrc:/Main.qml"));
    if(engine.rootObjects().isEmpty())return 1;
    if(preview) QTimer::singleShot(900,&app,[&] {
        auto *window=qobject_cast<QQuickWindow*>(engine.rootObjects().first());
        int i=app.arguments().indexOf("--screenshot");
        bool ok=window && i+1<app.arguments().size() && window->grabWindow().save(app.arguments().at(i+1));
        app.exit(ok?0:1);
    });
    return app.exec();
}
