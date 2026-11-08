import QtQuick
import QtQuick.Controls

Button {
    id: control
    property color ink: theme.foreground
    implicitHeight: 48
    leftPadding: 18; rightPadding: 18
    background: Rectangle {
        radius: theme.radius
        color: control.highlighted ? theme.accent : (control.down ? theme.background : "transparent")
        border.color: control.activeFocus || control.highlighted ? theme.accent : Qt.rgba(control.ink.r,control.ink.g,control.ink.b,.28)
        border.width: control.activeFocus ? 3 : 1
        opacity: control.enabled ? 1 : .55
    }
    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        font: control.font
        color: control.highlighted ? theme.accentForeground : theme.foreground
        opacity: control.enabled ? 1 : .55
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
