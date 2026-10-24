pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

// 2. Added a background Rectangle to fill the row
Rectangle {
    id: backgroundContainer
    color: "#2B4052"
    implicitWidth: rowLayout.width + 12 // Adding padding
    implicitHeight: 25
    property var monitor: hyprlandMonitor
    property var persistentWorkspaces
    readonly property int activeWorkspaceId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? -1

    Row {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4


        Repeater {
            model: {
                let wsSet = new Set(backgroundContainer.persistentWorkspaces);

                for (let ws of Hyprland.workspaces.values) {
                    if (ws.toplevels.values.length > 0) {
                        wsSet.add(ws.id);
                    }
                }

                if (backgroundContainer.activeWorkspaceId !== -1) {
                    wsSet.add(backgroundContainer.activeWorkspaceId);
                }
                return Array.from(wsSet).sort((a, b) => a - b);
            }

            delegate: Rectangle {
                id: dot
                required property int modelData
                readonly property bool isActive: modelData === backgroundContainer.activeWorkspaceId
                readonly property bool isEmpty: {
                    const ws = Hyprland.workspaces.values.find(w => w.id === modelData);
                    return !ws || ws.toplevels.values.length === 0;
                }

                implicitHeight: 20
                implicitWidth: 30
                radius: 2

                color: isActive ? "#CDCBE0" : "transparent"

                Text {
                    topPadding: 2
                    font.pixelSize: 18
                    font.weight: 500
                    font.family: "FiraCode Nerd Font"
                    anchors.centerIn: parent
                    text: modelData

                    // Contrast logic for the text
                    color: isActive ? "#191726" : (isEmpty ? "#696580" : "#CDCBE0")
                }

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch(`workspace ${dot.modelData}`);
                    }
                }
            }
        }
    }
}
