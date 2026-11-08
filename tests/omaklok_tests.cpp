#include <QtTest>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQuickStyle>
#include <QTemporaryDir>
#include <QFile>
#include "backend.h"
#include "theme.h"

class OmaKlokTests : public QObject {
    Q_OBJECT
private slots:
    void dutchTime() {
        Backend b(nullptr,false);
        QCOMPARE(b.spoken(390,false),QString("half zeven"));
        QCOMPARE(b.spoken(375,false),QString("kwart over zes"));
        QCOMPARE(b.spoken(405,false),QString("kwart voor zeven"));
        QCOMPARE(b.spoken(380,false),QString("tien voor half zeven"));
        QCOMPARE(b.spoken(395,false),QString("vijf over half zeven"));
        QCOMPARE(b.spoken(17*60+55),QString("vijf voor zes 's middags"));
        QCOMPARE(b.spoken(18*60),QString("zes uur 's avonds"));
        QCOMPARE(b.spoken(361,false),QString("één minuut over zes"));
        QCOMPARE(b.digital(1440),QString("00:00"));
        QCOMPARE(b.digital(-1),QString("23:59"));
        QCOMPARE(Backend::addMinutes(1435,10),5);
    }
    void generatedExercises() {
        Backend b(nullptr,false); b.setMode(0);
        for(int level=0;level<5;++level) {
            b.setDifficulty(level);
            for(int count=3;count<=5;++count) {
                b.setOptionCount(count);
                for(int i=0;i<180;++i) {
                    b.next();
                    QCOMPARE(b.options().size(),count);
                    QSet<int> seen;
                    for(const auto &v:b.options()) { QVERIFY(v.toInt()>=0 && v.toInt()<1440); seen.insert(v.toInt()); }
                    QCOMPARE(seen.size(),count);
                    QVERIFY(seen.contains(b.answer()));
                    if(level<4) QCOMPARE(b.time()%b.step(),0);
                    else { QVERIFY(!b.prompt().isEmpty()); QVERIFY(b.answer()!=b.time()); }
                }
            }
        }
    }
    void scoringAndRetry() {
        Backend b(nullptr,false); b.setMode(0);
        b.submit(); QCOMPARE(b.total(),0);
        int correct=b.options().indexOf(b.answer());
        b.setSelected((correct+1)%b.optionCount()); b.submit();
        QVERIFY(!b.solved()); QCOMPARE(b.total(),1); QCOMPARE(b.correct(),0);
        b.setSelected(correct); b.submit();
        QVERIFY(b.solved()); QCOMPARE(b.total(),1); QCOMPARE(b.correct(),0);
        b.submit(); QVERIFY(!b.solved());
        b.setSelected(b.options().indexOf(b.answer())); b.submit();
        QCOMPARE(b.correct(),1); QCOMPARE(b.total(),2);
    }
    void handsAndDayPeriod() {
        Backend b(nullptr,false); b.setMode(1);
        b.setInput(419); b.setHand(0,0); QCOMPARE(b.input(),420);
        b.setHand(0,59); QCOMPARE(b.input(),419);
        b.setInput(390); b.setHand(1,33); QCOMPARE(b.input(),390);
        b.setHand(0,45); QCOMPARE(b.input(),405);
        b.setHand(1,40); QCOMPARE(b.input(),465);
        b.nudge(720); QCOMPARE(b.input(),1185);
        b.setInput(b.answer()+720); b.submit(); QVERIFY(!b.solved());
        b.setInput(b.answer()); b.submit(); QVERIFY(b.solved());
        int frozen=b.input(); b.nudge(5); QCOMPARE(b.input(),frozen);
        b.next(); QVERIFY(b.input()!=b.answer());
    }
    void mixedAndBounds() {
        Backend b(nullptr,false); b.setMode(2);
        bool choice=false,hands=false;
        for(int i=0;i<100;++i) { b.next(); hands|=b.settingHands(); choice|=!b.settingHands(); }
        QVERIFY(choice && hands);
        b.setDifficulty(9); QCOMPARE(b.difficulty(),4);
        b.setOptionCount(1); QCOMPARE(b.optionCount(),3);
    }
    void followsThemeReplacement() {
        QTemporaryDir dir; QDir(dir.path()).mkpath("theme");
        Theme t(dir.path()); QCOMPARE(t.accent(),QString("#FFD60A"));
        auto write=[&](QByteArray bytes) { QFile f(dir.filePath("theme/colors.toml")); QVERIFY(f.open(QIODevice::WriteOnly)); f.write(bytes); };
        write("accent = \"#112233\"\nbackground = \"#ffffff\"\nforeground = \"#111111\"\n");
        QTRY_COMPARE(t.accent(),QString("#112233"));
        QVERIFY(t.light()); QCOMPARE(t.foreground(),QString("#111111"));
        QFile::remove(dir.filePath("theme/colors.toml"));
        write("accent = \"#ff0000\"\nbackground = \"#121212\"\n");
        QTRY_COMPARE(t.accent(),QString("#ff0000")); QVERIFY(!t.light());
    }
    void realWindowInteractions() {
        Backend b(nullptr,false); b.setMode(0);
        Theme t("/tmp/omaklok-tests-missing-theme");
        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("backend",&b);
        engine.rootContext()->setContextProperty("theme",&t);
        QStringList warnings;
        connect(&engine,&QQmlEngine::warnings,this,[&](const QList<QQmlError> &errors) { for(auto e:errors) warnings<<e.toString(); });
        engine.load(QUrl("qrc:/Main.qml"));
        QVERIFY(!engine.rootObjects().isEmpty());
        auto *w=qobject_cast<QQuickWindow*>(engine.rootObjects().first()); QVERIFY(w);
        w->requestActivate(); QTest::qWait(150);
        int answerIndex=b.options().indexOf(b.answer());
        QTest::keyClick(w,Qt::Key(int(Qt::Key_1)+answerIndex));
        QCOMPARE(b.selected(),answerIndex);
        QTest::keyClick(w,Qt::Key_Space); QVERIFY(b.solved());
        QTest::keyClick(w,Qt::Key_Space); QVERIFY(!b.solved());
        b.setMode(1); b.setInput(360);
        QTest::keyClick(w,Qt::Key_Right); QCOMPARE(b.input(),361);
        QTest::keyClick(w,Qt::Key_U); QTest::keyClick(w,Qt::Key_Up); QCOMPARE(b.input(),421);
        QTest::keyClick(w,Qt::Key_M);
        auto *clock=w->findChild<QQuickItem*>("practiceClock"); QVERIFY(clock);
        QTest::qWait(40);
        auto click=clock->mapToScene(QPointF(clock->width()-20,clock->height()/2));
        QTest::mouseClick(w,Qt::LeftButton,Qt::NoModifier,click.toPoint()); QCOMPARE(b.input()%60,15);
        b.setInput(b.answer()); QTest::keyClick(w,Qt::Key_Space); QVERIFY(b.solved());
        for(int level=0;level<5;++level) {
            b.setDifficulty(level);
            for(int mode=0;mode<2;++mode) { b.setMode(mode); for(int count=3;count<=5;++count) { b.setOptionCount(count); b.setSwapped(!b.swapped()); QTest::qWait(15); } }
        }
        b.setDifficulty(4); b.setMode(1);
        QTest::qWait(60); QVERIFY(w->grabWindow().save("story.png"));
        b.setDifficulty(0);
        QTest::qWait(60); QVERIFY(w->grabWindow().save("hands.png"));
        auto *help=w->findChild<QObject*>("helpDialog"); QVERIFY(help);
        QVERIFY(QMetaObject::invokeMethod(help,"open")); QTest::qWait(350);
        int before=b.input(); QTest::keyClick(w,Qt::Key_Right); QCOMPARE(b.input(),before);
        QVERIFY(w->grabWindow().save("interaction.png"));
        QVERIFY(QMetaObject::invokeMethod(help,"close")); QTest::qWait(350);
        w->resize(800,700); QTest::qWait(100); QVERIFY(w->grabWindow().save("compact.png"));
        QVERIFY2(warnings.isEmpty(),qPrintable(warnings.join('\n')));
    }
};
int main(int argc,char **argv) {
    QGuiApplication app(argc,argv); QQuickStyle::setStyle("Material");
    OmaKlokTests tests; return QTest::qExec(&tests,argc,argv);
}
#include "omaklok_tests.moc"
