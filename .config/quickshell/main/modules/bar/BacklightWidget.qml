import QtQuick
import QtQuick.Layouts
import qs.services

Rectangle {
    id: root

    width: row.implicitWidth + 5
    height: 25
    color: "#2B4052"

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: Backlight.iconName
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
            color: "#CDCBE0"
        }

        Text {
            text: `${Math.round(Backlight.percent).toString().padStart(3, "0")}%`
            font.pixelSize: 18
            font.family: "monospace"
            color: "#CDCBE0"
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

