import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Rectangle {
    Layout.alignment: Qt.AlignHCenter
    width: 108   // Swapped from height
    height: 25  // Swapped from width
    color: "#2B4052"

    readonly property PwNode sink: Pipewire.defaultAudioSink

    property bool muted: sink?.audio?.muted ?? false
    property real volume: sink?.audio?.volume ?? 0
    property real currentVolume: 1
    property real lastVolume: 0

    PwObjectTracker {
        id: pwObjectTracker
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    SequentialAnimation {
        id: bounceAnimation
        PropertyAnimation {
            target: volumeBar
            property: "anchors.leftMargin" // Changed from bottomMargin
            to: -4
            duration: 120
            easing.type: Easing.OutBack
        }
        PropertyAnimation {
            target: volumeBar
            property: "anchors.leftMargin"
            to: 6
            duration: 180
            easing.type: Easing.InOutBounce
        }
        // ... (remaining steps omitted for conciseness, keep your existing logic but use leftMargin)
        PropertyAnimation {
            target: volumeBar
            property: "anchors.leftMargin"
            to: 0
            duration: 160
            easing.type: Easing.OutElastic
        }
    }

    onVolumeChanged: {
        if (Math.abs(volume - lastVolume) > 0.01) {
            bounceAnimation.start()
            lastVolume = volume
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        // Volume bar (Horizontal)
        Rectangle {
            id: volumeBar
            Layout.alignment: Qt.AlignVCenter
            width: muted ? 0 : 75
            height: 12
            color: "#CDCBE0"
            radius: 10

            Rectangle {
                anchors.left: parent.left // Changed from bottom
                anchors.verticalCenter: parent.verticalCenter
                color: "#191726"
                height: parent.height
                width: { // Logic changed from height to width
                    let len = muted ? 0 : parent.width * volume;
                    return (len > parent.width) ? parent.width : len;
                }
                radius: 10
                Behavior on width { // Changed from height
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // Speaker icon
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 14
            height: 12
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: muted ? "  󰝟" : "  󰕾"
                color: "#CDCBE0"
                font.pixelSize: 18
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { sink.audio.muted = !muted; }
        onWheel: wheel => {
            if (sink && !muted) {
                let delta = wheel.angleDelta.y > 0 ? 0.1 : -0.1
                let newVolume = volume + delta
                newVolume = Math.max(0, Math.min(1, newVolume))
                sink.audio.volume = newVolume
            }
        }
    }
}
