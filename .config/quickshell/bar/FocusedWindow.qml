import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    id: windowModule

    height: 25
    width: Math.min(titleText.implicitWidth + 5, 500)
    color: "transparent"

    // Imperative call on startup
    Component.onCompleted: {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
    }

    readonly property string windowTitle: Hyprland.activeToplevel?.title ?? "None"

    RowLayout {
        anchors.fill: parent
        Text {
            id: titleText
            font.pixelSize: 12
            font.weight: 500
            font.family: "FiraCode Nerd Font"
            topPadding: 2
            color: "#696580"
            text: windowModule.windowTitle

            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
