import QtQuick

Item {
    id: clock
    property int minutes: 0
    property bool editable: false
    property int activeHand: 0
    property color ink: theme.foreground
    property color accent: theme.accent
    signal handMoved(int hand, int tick)
    implicitWidth: 340
    implicitHeight: 340
    Accessible.role: editable ? Accessible.Slider : Accessible.Graphic
    Accessible.name: editable ? "Analoge oefenklok. Gebruik pijltjestoetsen om de wijzers te verzetten." : "Analoge klok. Lees de wijzers."
    function update(x,y) {
        let angle = Math.atan2(x-width/2, height/2-y)
        let tick = Math.round((angle*30/Math.PI+60)%60)%60
        handMoved(activeHand,tick)
    }
    Rectangle {
        anchors.fill: parent
        radius: width/2
        color: theme.background
        border.width: 2
        border.color: theme.accent
    }
    Repeater {
        model: 60
        Rectangle {
            required property int index
            width: index%5===0 ? 3 : 1
            height: index%5===0 ? clock.width*.04 : clock.width*.016
            color: clock.ink
            opacity: index%5===0 ? .8 : .35
            x: clock.width/2-width/2
            y: clock.width*.04
            transform: Rotation { origin.x: 1; origin.y: clock.height/2-clock.width*.04; angle: index*6 }
        }
    }
    Repeater {
        model: 12
        Text {
            required property int index
            text: index===0 ? "12" : index
            font.pixelSize: Math.round(clock.width*.068)
            font.bold: true
            color: clock.ink
            x: clock.width/2+Math.sin(index*Math.PI/6)*clock.width*.365-width/2
            y: clock.height/2-Math.cos(index*Math.PI/6)*clock.height*.365-height/2
        }
    }
    Rectangle {
        objectName: "hourHand"
        width: 10; height: clock.height*.235
        radius: 5
        color: clock.ink
        x: clock.width/2-width/2; y: clock.height/2-height
        transform: Rotation { origin.x: 5; origin.y: clock.height*.235; angle: (clock.minutes%720)*.5 }
    }
    Rectangle {
        objectName: "minuteHand"
        width: 6; height: clock.height*.32
        radius: 3
        color: clock.accent
        x: clock.width/2-width/2; y: clock.height/2-height
        transform: Rotation { origin.x: 3; origin.y: clock.height*.32; angle: (clock.minutes%60)*6 }
    }
    Rectangle { anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: clock.accent }
    MouseArea {
        objectName: "clockDrag"
        anchors.fill: parent
        enabled: clock.editable
        preventStealing: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: function(mouse) { clock.update(mouse.x,mouse.y) }
        onPositionChanged: function(mouse) { if(pressed) clock.update(mouse.x,mouse.y) }
    }
}
