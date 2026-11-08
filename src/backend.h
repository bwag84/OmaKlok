#pragma once
#include <QObject>
#include <QVariantList>
#include <QSettings>

class Backend : public QObject {
    Q_OBJECT
    Q_PROPERTY(int difficulty READ difficulty WRITE setDifficulty NOTIFY changed)
    Q_PROPERTY(int mode READ mode WRITE setMode NOTIFY changed)
    Q_PROPERTY(int optionCount READ optionCount WRITE setOptionCount NOTIFY changed)
    Q_PROPERTY(bool swapped READ swapped WRITE setSwapped NOTIFY changed)
    Q_PROPERTY(int time READ time NOTIFY changed)
    Q_PROPERTY(int answer READ answer NOTIFY changed)
    Q_PROPERTY(int input READ input NOTIFY changed)
    Q_PROPERTY(bool settingHands READ settingHands NOTIFY changed)
    Q_PROPERTY(QString prompt READ prompt NOTIFY changed)
    Q_PROPERTY(QString feedback READ feedback NOTIFY changed)
    Q_PROPERTY(bool solved READ solved NOTIFY changed)
    Q_PROPERTY(QVariantList options READ options NOTIFY changed)
    Q_PROPERTY(int selected READ selected WRITE setSelected NOTIFY changed)
    Q_PROPERTY(int correct READ correct NOTIFY changed)
    Q_PROPERTY(int total READ total NOTIFY changed)
    Q_PROPERTY(int step READ step NOTIFY changed)
public:
    explicit Backend(QObject *parent = nullptr, bool persist = true);
    int difficulty() const { return m_difficulty; }
    int mode() const { return m_mode; }
    int optionCount() const { return m_optionCount; }
    bool swapped() const { return m_swapped; }
    int time() const { return m_time; }
    int answer() const { return m_answer; }
    int input() const { return m_input; }
    bool settingHands() const { return m_settingHands; }
    QString prompt() const { return m_prompt; }
    QString feedback() const { return m_feedback; }
    bool solved() const { return m_solved; }
    QVariantList options() const { return m_options; }
    int selected() const { return m_selected; }
    int correct() const { return m_correct; }
    int total() const { return m_total; }
    int step() const;
    void setDifficulty(int value);
    void setMode(int value);
    void setOptionCount(int value);
    void setSwapped(bool value);
    void setSelected(int value);
    Q_INVOKABLE void next();
    Q_INVOKABLE void submit();
    Q_INVOKABLE void setInput(int value);
    Q_INVOKABLE void nudge(int minutes);
    Q_INVOKABLE void setHand(int hand, int tick);
    Q_INVOKABLE QString digital(int time) const;
    Q_INVOKABLE QString spoken(int time, bool period = true) const;
    static int wrap(int value) { return (value % 1440 + 1440) % 1440; }
    static int addMinutes(int time, int duration) { return wrap(time + duration); }
signals:
    void changed();
private:
    void save();
    bool m_persist;
    int m_difficulty = 0, m_mode = 2, m_optionCount = 3;
    bool m_swapped = false, m_settingHands = false, m_solved = false, m_attempted = false;
    int m_time = 360, m_answer = 360, m_input = 0, m_selected = -1, m_correct = 0, m_total = 0;
    QString m_prompt, m_feedback;
    QVariantList m_options;
};
