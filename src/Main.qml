import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: win
    width: 1100; height: 820
    minimumWidth: 800; minimumHeight: 700
    visible: true
    title: "OmaKlok · Spelen met tijd"
    color: theme.background
    Material.theme: theme.light ? Material.Light : Material.Dark
    Material.accent: theme.accent
    Material.foreground: theme.foreground
    Material.background: theme.surface
    Material.roundedScale: theme.radius
    font.family: "Sans Serif"
    font.pixelSize: 17
    property int activeHand: 0
    property bool blocked: help.visible || settings.visible
    function primary() { if(!blocked) backend.submit() }
    function move(v) { if(!blocked && backend.settingHands && !backend.solved) backend.nudge(v) }
    Shortcut { sequence: "Space"; context: Qt.ApplicationShortcut; onActivated: win.primary() }
    Shortcut { sequence: "Return"; context: Qt.ApplicationShortcut; onActivated: win.primary() }
    Shortcut { sequence: "?"; context: Qt.ApplicationShortcut; onActivated: help.open() }
    Shortcut { sequence: "Q"; context: Qt.ApplicationShortcut; onActivated: Qt.quit() }
    Shortcut { sequence: "Left"; context: Qt.ApplicationShortcut; onActivated: win.move(win.activeHand===0 ? -1 : -60) }
    Shortcut { sequence: "Right"; context: Qt.ApplicationShortcut; onActivated: win.move(win.activeHand===0 ? 1 : 60) }
    Shortcut { sequence: "Up"; context: Qt.ApplicationShortcut; onActivated: win.move(win.activeHand===0 ? 5 : 60) }
    Shortcut { sequence: "Down"; context: Qt.ApplicationShortcut; onActivated: win.move(win.activeHand===0 ? -5 : -60) }
    Shortcut { sequence: "M"; context: Qt.ApplicationShortcut; onActivated: win.activeHand=0 }
    Shortcut { sequence: "U"; context: Qt.ApplicationShortcut; onActivated: win.activeHand=1 }
    Shortcut { sequence: "1"; context: Qt.ApplicationShortcut; onActivated: if(!win.blocked && !backend.settingHands && 0<backend.optionCount) backend.selected=0 }
    Shortcut { sequence: "2"; context: Qt.ApplicationShortcut; onActivated: if(!win.blocked && !backend.settingHands && 1<backend.optionCount) backend.selected=1 }
    Shortcut { sequence: "3"; context: Qt.ApplicationShortcut; onActivated: if(!win.blocked && !backend.settingHands && 2<backend.optionCount) backend.selected=2 }
    Shortcut { sequence: "4"; context: Qt.ApplicationShortcut; onActivated: if(!win.blocked && !backend.settingHands && 3<backend.optionCount) backend.selected=3 }
    Shortcut { sequence: "5"; context: Qt.ApplicationShortcut; onActivated: if(!win.blocked && !backend.settingHands && 4<backend.optionCount) backend.selected=4 }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: win.height<780 ? 20 : 28
        spacing: win.height<780 ? 10 : 16
        RowLayout {
            Layout.fillWidth: true
            Rectangle {
                width: 46; height: 46; radius: 23; color: theme.accent
                Text { anchors.centerIn: parent; text: "◷"; font.pixelSize: 36; color: theme.accentForeground }
            }
            ColumnLayout {
                spacing: 0
                Label { text: "OmaKlok"; font.pixelSize: 30; font.bold: true }
                Label { text: qsTr("Elke minuut iets slimmer"); font.pixelSize: 14; opacity: .7 }
            }
            Item { Layout.fillWidth: true }
            KlokButton { text: qsTr("Hulp  ?"); onClicked: help.open() }
            KlokButton { text: qsTr("Instellingen"); onClicked: settings.open() }
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: theme.foreground; opacity: .15 }
        RowLayout {
            Layout.fillWidth: true
            Label { text: [qsTr("1 · Hele en halve uren"),qsTr("2 · Kwartieren"),qsTr("3 · Vijf minuten"),qsTr("4 · Elke minuut"),qsTr("5 · Tijdverhalen")][backend.difficulty]; color: theme.accent; font.bold: true }
            Item { Layout.fillWidth: true }
            Label { objectName: "score"; text: qsTr("%1 van %2 in één keer goed").arg(backend.correct).arg(backend.total); font.pixelSize: 15; opacity: .8 }
        }
        Label {
            objectName: "question"
            Layout.fillWidth: true
            Layout.minimumHeight: 66
            text: backend.prompt
            wrapMode: Text.WordWrap
            font.pixelSize: backend.difficulty===4 ? 25 : 29
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        RowLayout {
            id: exercise
            Layout.fillWidth: true; Layout.fillHeight: true
            spacing: 20
            layoutDirection: backend.swapped ? Qt.RightToLeft : Qt.LeftToRight
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: theme.surface; radius: theme.radius
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 10
                    Label { Layout.alignment: Qt.AlignHCenter; text: backend.settingHands ? qsTr("Jouw wijzerklok") : qsTr("Kijk naar de wijzers"); font.bold: true; opacity: .8 }
                    Item { Layout.fillHeight: true }
                    PracticeClock {
                        id: practiceClock
                        objectName: "practiceClock"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.max(100,Math.min(320,exercise.width/2-60,exercise.height-(backend.settingHands ? 195 : 110)))
                        Layout.preferredHeight: Layout.preferredWidth
                        minutes: backend.settingHands ? backend.input : backend.time
                        editable: backend.settingHands && !backend.solved
                        activeHand: win.activeHand
                        onHandMoved: function(hand,tick) { backend.setHand(hand,tick) }
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        visible: backend.settingHands
                        KlokButton { objectName: "minuteButton"; text: qsTr("Grote wijzer"); highlighted: win.activeHand===0; onClicked: win.activeHand=0 }
                        KlokButton { objectName: "hourButton"; text: qsTr("Kleine wijzer"); highlighted: win.activeHand===1; onClicked: win.activeHand=1 }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: backend.settingHands ? qsTr("Kies een wijzer en sleep op de klok.\nOf gebruik de pijltjestoetsen.") : backend.spoken(Math.floor(backend.time/60)*60).split(" uur").slice(1).join(" uur").trim()
                        wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14; opacity: .7
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true; Layout.preferredWidth: 1
                color: theme.surface; radius: theme.radius
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 22; spacing: 8
                    Label { Layout.alignment: Qt.AlignHCenter; text: backend.settingHands ? qsTr("Denk rustig na") : qsTr("Kies de digitale klok"); font.bold: true; opacity: .8 }
                    Item { Layout.fillHeight: true }
                    Repeater {
                        model: backend.settingHands ? [] : backend.options
                        KlokButton {
                            required property int index
                            required property var modelData
                            objectName: "option"+index
                            Layout.fillWidth: true
                            Layout.preferredHeight: backend.optionCount===5 ? 55 : 70
                            background: Rectangle {
                                radius: theme.radius
                                color: backend.selected===index ? theme.accent : theme.background
                                border.color: theme.accent
                                border.width: backend.selected===index ? 3 : 1
                                opacity: backend.selected===index ? 1 : .7
                            }
                            highlighted: backend.selected===index
                            enabled: !backend.solved
                            Accessible.name: qsTr("Antwoord %1: %2").arg(index+1).arg(backend.digital(modelData))
                            contentItem: RowLayout {
                                Label { text: String(index+1); opacity: .6; font.pixelSize: 16; leftPadding: 14; color: backend.selected===index ? theme.accentForeground : theme.foreground }
                                Label { text: backend.digital(modelData); font.family: "Monospace"; font.pixelSize: backend.optionCount===5 ? 28 : 34; font.bold: true; color: backend.selected===index ? theme.accentForeground : theme.foreground; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                                Label { text: backend.selected===index ? "●" : "○"; rightPadding: 14; color: backend.selected===index ? theme.accentForeground : theme.accent }
                            }
                            onClicked: backend.selected=index
                        }
                    }
                    Label {
                        visible: backend.settingHands
                        Layout.fillWidth: true
                        text: backend.solved ? backend.digital(backend.answer) : "◷"
                        color: theme.accent
                        font.pixelSize: backend.solved ? 46 : (win.height<780 ? 48 : 64)
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        visible: backend.settingHands
                        Layout.fillWidth: true
                        text: backend.difficulty===4 ? qsTr("Reken vooruit vanaf %1 (%2).\nZet daarna jouw klok op het antwoord.").arg(backend.digital(backend.time)).arg(backend.spoken(backend.time)) : qsTr("De kleine wijzer vertelt het uur.\nDe grote wijzer vertelt de minuten.")
                        wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: win.height<780 ? 16 : 20
                    }
                    RowLayout {
                        visible: backend.settingHands
                        Layout.alignment: Qt.AlignHCenter
                        KlokButton { objectName: "periodButton"; text: backend.input<720 ? qsTr("Voor de middag (00–11)") : qsTr("Na de middag (12–23)"); onClicked: backend.nudge(720); enabled: !backend.solved }
                    }
                    Label { visible: backend.settingHands; Layout.fillWidth: true; text: qsTr("Een wijzerklok draait twee keer per dag rond.\nKies daarom ook het juiste dagdeel."); font.pixelSize: 14; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; opacity: .7 }
                    Item { Layout.fillHeight: true }
                }
            }
        }
        Label {
            objectName: "feedback"
            Layout.fillWidth: true; Layout.minimumHeight: 52
            text: backend.feedback || (backend.settingHands ? qsTr("Klaar met zetten? Druk op spatie om te controleren.") : qsTr("Klik op een tijd en druk op spatie om te controleren."))
            wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
            color: backend.solved ? theme.accent : theme.foreground
            font.pixelSize: 17
            Accessible.role: Accessible.AlertMessage
        }
        RowLayout {
            Layout.fillWidth: true
            KlokButton { text: qsTr("⇄  Wissel kanten"); onClicked: backend.swapped=!backend.swapped }
            Item { Layout.fillWidth: true }
            KlokButton { objectName: "submitButton"; text: backend.solved ? qsTr("Volgende vraag  →") : qsTr("Controleer  ✓"); highlighted: true; Layout.preferredWidth: 240; onClicked: backend.submit() }
            Item { Layout.fillWidth: true }
            KlokButton { text: qsTr("Andere vraag"); onClicked: backend.next() }
        }
    }
    Dialog {
        id: settings
        objectName: "settingsDialog"
        anchors.centerIn: parent; width: Math.min(640,win.width-50)
        modal: true; title: qsTr("Zo wil ik oefenen")
        background: Rectangle { color: theme.surface; radius: theme.radius; border.width: 1; border.color: theme.accent }
        footer: DialogButtonBox {
            KlokButton { text: qsTr("Sluiten"); DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
            onRejected: settings.close()
        }
        ColumnLayout {
            width: parent.width; spacing: 10
            Label { text: qsTr("Moeilijkheid"); font.bold: true }
            ComboBox {
                objectName: "difficultyPicker"
                Layout.fillWidth: true
                model: [qsTr("1 · Hele en halve uren"),qsTr("2 · Ook kwartieren"),qsTr("3 · Stappen van vijf minuten"),qsTr("4 · Alle minuten ertussen"),qsTr("5 · Verhalen: rekenen met tijd")]
                currentIndex: backend.difficulty
                onActivated: backend.difficulty=currentIndex
            }
            Label { text: qsTr("Oefenvorm"); font.bold: true }
            ComboBox { objectName: "modePicker"; Layout.fillWidth: true; model: [qsTr("Kies het juiste antwoord"),qsTr("Zet zelf de wijzers"),qsTr("Wissel beide vormen af")]; currentIndex: backend.mode; onActivated: backend.mode=currentIndex }
            Label { text: qsTr("Aantal antwoorden"); font.bold: true }
            ComboBox { Layout.fillWidth: true; model: ["3", "4", "5"]; currentIndex: backend.optionCount-3; onActivated: backend.optionCount=currentIndex+3 }
            Label { Layout.fillWidth: true; text: qsTr("Je instellingen worden bewaard. Je score telt alleen je eerste poging. Fouten maken mag: je kunt altijd opnieuw proberen!"); wrapMode: Text.WordWrap; font.pixelSize: 15; opacity: .8 }
        }
    }
    Dialog {
        id: help
        objectName: "helpDialog"
        anchors.centerIn: parent
        width: Math.min(710,win.width-50); height: Math.min(650,win.height-50)
        title: qsTr("Een handje hulp")
        modal: true
        background: Rectangle { color: theme.surface; radius: theme.radius; border.width: 1; border.color: theme.accent }
        footer: DialogButtonBox {
            KlokButton { text: qsTr("Sluiten"); DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
            onRejected: help.close()
        }
        ScrollView {
            anchors.fill: parent; clip: true
            contentWidth: availableWidth
            Label {
                width: help.availableWidth-20
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                text: qsTr("<h2>Zo lees je de klok</h2><p><b>De kleine wijzer</b> wijst het uur aan. Hij schuift langzaam mee tussen twee cijfers.</p><p><b>De grote wijzer</b> wijst de minuten aan. Elk streepje is één minuut. Van cijfer naar cijfer zijn het vijf minuten. Eén rondje duurt zestig minuten.</p><p><b>Hele uren:</b> de grote wijzer staat op 12. Bij zes uur staat de kleine wijzer op 6.</p><p><b>Half zeven = 6:30.</b> We zijn halverwege op weg naar zeven! De grote wijzer staat op 6 en de kleine tussen 6 en 7.</p><p><b>Kwart over zes = 6:15.</b> De grote wijzer staat op 3.<br><b>Kwart voor zeven = 6:45.</b> De grote wijzer staat op 9.</p><p><b>6:20</b> zeg je als ‘tien voor half zeven’. <b>6:35</b> is ‘vijf over half zeven’.</p><h2>Ochtend of avond?</h2><p>Een digitale klok telt tot 24. Zes uur 's ochtends is <b>06:00</b>. Zes uur 's avonds is <b>18:00</b>. Na 23:59 komt 00:00: een nieuwe dag!</p><h2>Rekenen met tijd</h2><p>Het is 17:55. Mama zegt: ‘Over vijf minuten eten we.’ Tel vijf minuten vooruit: <b>18:00</b>. Bij zestig minuten begint een nieuw uur.</p><h2>Zelf de wijzers zetten</h2><p>Kies <b>Grote wijzer</b> of <b>Kleine wijzer</b>. Klik of sleep op de klok. Kies ook ‘voor de middag’ of ‘na de middag’.</p><p><b>M / U</b> kiest de minutenwijzer / uurwijzer.<br><b>← / →</b> één minuut of één uur terug / vooruit.<br><b>↑ / ↓</b> vijf minuten of één uur vooruit / terug.<br><b>1–5</b> kiest een antwoord.<br><b>Spatie / Enter</b> controleert of gaat verder.<br><b>?</b> opent deze hulp. <b>Q</b> sluit OmaKlok.</p><p>Neem de tijd. Je hoeft het niet meteen goed te doen. Samen oefenen helpt!</p>")
            }
        }
    }
}
