import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    implicitWidth: blText.implicitWidth
    implicitHeight: 25
    color: "#2B4052"
    readonly property list<string> icons: ["", "", "", "", "", "", "", "", ""]
    readonly property int stepCount: 1
    property int lightLvl: Math.floor(getCC.brightness * 100 / getMax.brightness)

    Text {
        id: blText
        topPadding: 2
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 18
        font.weight: 500
        color: "#CDCBE0"
    }

    Process {
        id: setBlText
        command: ["sh", "-c", "brightnessctl g"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let idx = Math.min(Math.floor(root.lightLvl / 11.2), 8);
                let icon = root.icons[idx];
                blText.text = icon + " " + root.lightLvl.toString().padStart(3, "0") + "%";
            }
        }
    }

    Process {
        id: setBlLvl
        command: ["sh", "-c", "brightnessctl s " + root.lightLvl + "%"]
        running: false
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            let step = root.stepCount;
            if (wheel.angleDelta.y > 0) {
                root.lightLvl = Math.min(root.lightLvl + step, 100);
                setBlLvl.running = true
            } else {
                root.lightLvl = Math.max(root.lightLvl - step, 1);
                setBlLvl.running = true
            }
        }

    }

    FileView {
        id: getCC
        path: "/sys/class/backlight/intel_backlight/actual_brightness"
        property int brightness: parseInt(data());

        watchChanges: true
        onFileChanged: {
            brightness = parseInt(data());
            setBlText.running = true;
        }
    }

    FileView {
        id: getMax
        path: "/sys/class/backlight/intel_backlight/max_brightness"
        property int brightness: parseInt(data());
    }

}
