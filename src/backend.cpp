#include "backend.h"
#include <QRandomGenerator>
#include <QSet>
#include <algorithm>
#include <random>

Backend::Backend(QObject *parent, bool persist) : QObject(parent), m_persist(persist) {
    if (persist) {
        QSettings s;
        m_difficulty = qBound(0, s.value("difficulty", 0).toInt(), 4);
        m_mode = qBound(0, s.value("mode", 2).toInt(), 2);
        m_optionCount = qBound(3, s.value("options", 3).toInt(), 5);
        m_swapped = s.value("swapped", false).toBool();
    }
    next();
}
void Backend::save() {
    if (!m_persist) return;
    QSettings s;
    s.setValue("difficulty", m_difficulty); s.setValue("mode", m_mode);
    s.setValue("options", m_optionCount); s.setValue("swapped", m_swapped);
}
void Backend::setDifficulty(int v) { v=qBound(0,v,4); if(v==m_difficulty)return; m_difficulty=v; save(); next(); }
void Backend::setMode(int v) { v=qBound(0,v,2); if(v==m_mode)return; m_mode=v; save(); next(); }
void Backend::setOptionCount(int v) { v=qBound(3,v,5); if(v==m_optionCount)return; m_optionCount=v; save(); next(); }
void Backend::setSwapped(bool v) { m_swapped=v; save(); emit changed(); }
void Backend::setSelected(int v) { if(m_solved)return; m_selected=qBound(-1,v,m_options.size()-1); emit changed(); }
int Backend::step() const { return m_difficulty==0 ? 30 : m_difficulty==1 ? 15 : m_difficulty==2 || m_difficulty==4 ? 5 : 1; }
QString Backend::digital(int t) const { t=wrap(t); return QString("%1:%2").arg(t/60,2,10,QChar('0')).arg(t%60,2,10,QChar('0')); }
QString Backend::spoken(int t, bool period) const {
    t=wrap(t);
    const QStringList words={"twaalf","één","twee","drie","vier","vijf","zes","zeven","acht","negen","tien","elf"};
    int h=t/60, m=t%60;
    QString a=words[h%12], b=words[(h+1)%12], text;
    auto minutes=[](int n) { return n==1 ? QString("één minuut") : QString("%1 minuten").arg(n); };
    if(m==0) text=a+" uur";
    else if(m==15) text="kwart over "+a;
    else if(m==30) text="half "+b;
    else if(m==45) text="kwart voor "+b;
    else if(m==5 || m==10) text=words[m]+" over "+a;
    else if(m==20 || m==25) text=words[30-m]+" voor half "+b;
    else if(m==35 || m==40) text=words[m-30]+" over half "+b;
    else if(m==50 || m==55) text=words[60-m]+" voor "+b;
    else if(m<30) text=minutes(m)+" over "+a;
    else text=minutes(60-m)+" voor "+b;
    if(period) text += h<6 ? " 's nachts" : h<12 ? " 's ochtends" : h<18 ? " 's middags" : " 's avonds";
    return text;
}
void Backend::next() {
    auto *r=QRandomGenerator::global();
    m_solved=false; m_attempted=false; m_feedback.clear(); m_selected=-1;
    m_settingHands=m_mode==1 || (m_mode==2 && r->bounded(2)==1);
    m_time=(6+r->bounded(15))*60 + r->bounded(60/step())*step();
    m_answer=m_time;
    if(m_difficulty==4) {
        struct Story { int time; int wait; const char *text; };
        static const Story stories[]={
            {17*60+55,5,"Mama roept: ‘Over vijf minuten gaan we eten!’ Hoe laat eten we?"},
            {8*60+10,20,"Over twintig minuten begint school. Hoe laat begint school?"},
            {14*60+45,15,"Je vriendje komt over een kwartier spelen. Hoe laat komt hij?"},
            {16*60+20,10,"Over tien minuten vertrekken we naar dansles. Hoe laat vertrekken we?"},
            {15*60+50,10,"Over tien minuten begint zwemles. Hoe laat begint zwemles?"},
            {18*60+28,2,"Over twee minuten moet je je handen wassen. Hoe laat is dat?"},
            {19*60+40,20,"Over twintig minuten lezen we een verhaaltje. Hoe laat is dat?"},
            {12*60+55,10,"Over tien minuten gaan we buiten spelen. Hoe laat is dat?"},
            {7*60+50,15,"Over een kwartier vertrekken we naar school. Hoe laat vertrekken we?"},
            {23*60+55,10,"Het is oudejaarsavond! Over tien minuten steken we sterretjes aan. Hoe laat is dat?"}
        };
        const auto &s=stories[r->bounded(int(sizeof(stories)/sizeof(Story)))];
        m_time=s.time; m_answer=addMinutes(s.time,s.wait); m_prompt=QString::fromUtf8(s.text);
    } else m_prompt=m_settingHands ? "Zet de klok op "+spoken(m_answer)+"." : "Hoe laat is het?";
    // Start away from the answer, so every hands exercise needs an action.
    m_input=wrap(m_answer+65);
    // Every question asks children to read both hands: include a wrong
    // minute position as well as a wrong hour, even with only three choices.
    QSet<int> unique{m_answer, wrap(m_answer+(r->bounded(2) ? step() : -step())),
                     wrap(m_answer+(r->bounded(2) ? 60 : -60))};
    QList<int> offsets{step(),-step(),60,-60,2*step(),-2*step(),120,-120};
    for(int i=offsets.size()-1;i>0;--i) offsets.swapItemsAt(i,r->bounded(i+1));
    for(int d:offsets) { if(unique.size()>=m_optionCount) break; unique.insert(wrap(m_answer+d)); }
    m_options.clear(); for(int t:unique) m_options.append(t);
    for(int i=m_options.size()-1;i>0;--i) m_options.swapItemsAt(i,r->bounded(i+1));
    emit changed();
}
void Backend::setInput(int v) { if(m_solved)return; m_input=wrap(v); m_feedback.clear(); emit changed(); }
void Backend::nudge(int v) { setInput(m_input+v); }
void Backend::setHand(int hand,int tick) {
    tick=(tick%60+60)%60;
    if(hand==0) {
        // Crossing twelve carries the hour, like turning a real clock hand.
        int delta=tick-m_input%60;
        if(delta>30) delta-=60;
        if(delta < -30) delta+=60;
        setInput(m_input+delta);
    }
    else {
        int hour=(qRound(tick/5.0-(m_input%60)/60.0)+12)%12;
        setInput((m_input/720)*720+hour*60+m_input%60);
    }
}
void Backend::submit() {
    if(m_solved) { next(); return; }
    if(!m_settingHands && m_selected<0) { m_feedback="Kies eerst een klok. Je kunt ook de toetsen 1 tot en met 5 gebruiken."; emit changed(); return; }
    int guess=m_settingHands ? m_input : m_options[m_selected].toInt();
    bool ok=guess==m_answer;
    if(!m_attempted) { ++m_total; if(ok) ++m_correct; m_attempted=true; }
    m_solved=ok;
    m_feedback=ok ? "Goed gedaan! "+digital(m_answer)+" is "+spoken(m_answer)+". Druk op spatie voor de volgende vraag." : "Bijna! Kijk naar de kleine wijzer (uren), de grote wijzer (minuten) en het dagdeel. Probeer het nog eens.";
    emit changed();
}
