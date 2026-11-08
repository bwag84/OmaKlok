import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

// The shell entry point opens the native app. It never builds or installs code.
Item {
    id: root
    property QtObject bar: null
    property var settings: ({})
    property string moduleName: "bwag84.omaklok"
    property string fixedEdge: "center"
    property bool opened: false
    implicitWidth: title.implicitWidth + 20
    implicitHeight: bar ? bar.barSize : 32
    function open(payloadJson) { if(!check.running) check.running=true }
    function close() { opened=false; missing.visible=false }
    function toggle() { open("") }
    Process {
        id: check
        command: ["sh", "-c", "command -v omaklok >/dev/null 2>&1"]
        onExited: function(code,status) {
            if(code===0) { Quickshell.execDetached(["omaklok"]); root.opened=false }
            else { root.opened=true; missing.visible=true }
        }
    }
    Text {
        id: title; textFormat: Text.PlainText; anchors.centerIn: parent; text: "◷ OmaKlok"
        font.pixelSize: 14
        color: root.bar && root.bar.foreground ? root.bar.foreground : "#FFD60A"
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.open("") }
    FloatingWindow {
        id: missing
        visible: false
        title: "OmaKlok installeren"
        implicitWidth: 480; implicitHeight: 220
        color: "#171b26"
        Column {
            anchors.fill: parent; anchors.margins: 24; spacing: 16
            Text { textFormat: Text.PlainText; text: "Installeer eerst de OmaKlok desktopapp"; color: "#edf0f7"; font.pixelSize: 20; font.bold: true; width: parent.width; wrapMode: Text.WordWrap }
            Text { textFormat: Text.PlainText; text: "Voer in de repository bin/install uit voor het Arch-pakket, of bin/install-user zonder sudo. De plugin installeert niets automatisch."; color: "#edf0f7"; width: parent.width; wrapMode: Text.WordWrap }
            Button { text: "Sluiten"; onClicked: root.close() }
        }
    }
}
