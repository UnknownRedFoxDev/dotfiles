import QtQuick
import QtQuick.Layouts
import qs.services

Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 16
    implicitHeight: 22
    radius: 4
    color: wheel.contains || dragArea.pressed ? "#e8e8e8" : "transparent"

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: Backlight.iconName
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
            color: "#333333"
        }

        Text {
            text: `${Math.round(Backlight.percent).toString().padStart(3, "0")}%`
            font.pixelSize: 12
            font.family: "monospace"
            color: "#333333"
        }

    }
    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true

        onPressed: mouse => Backlight.setPercent(mouse.x / root.width * 100)
        onPositionChanged: mouse => {
            if (pressed) {
                Backlight.setPercent(mouse.x / root.width * 100);
            }
        }
    }

    MouseArea {
        id: wheel
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.NoButton
        onWheel: wheelEvent => {
            Backlight.step(wheelEvent.angleDelta.y > 0 ? 2 : -2);
        }
    }
}
