pragma Singleton

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpuTemp
    property string degree: "0°C "
    property list<string> icons: [" ", " "]
    property string icon: " "

    FolderListModel {
        id: folderListModel
        folder: "file:///sys/class/hwmon"
    }

    FileView {
        id: hwmon

        property int index: 0
        property bool done: false
        property string fileName: "name"

        path: folderListModel.status === FolderListModel.Ready ? `file:///sys/class/hwmon/hwmon${Math.min(index, folderListModel.count - 1)}/${fileName}` : ""

        onLoaded: {
            if (!done) {
                if (text().includes("coretemp")) {
                    Qt.callLater(() => {
                        done = true;
                        fileName = "temp1_input";
                    });
                } else if (index < folderListModel.count - 1)
                Qt.callLater(() => ++index);
            } else
            root.cpuTemp = Number(text()) / 1000;
            root.degree = root.icon + root.cpuTemp + "°C"
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: hwmon.reload()
    }
}

