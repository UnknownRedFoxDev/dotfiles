import QtQuick
import Quickshell

PanelWindow {
    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 32
    color: "#ffffff"

    Item {
        anchors.fill: parent

        BacklightWidget {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
