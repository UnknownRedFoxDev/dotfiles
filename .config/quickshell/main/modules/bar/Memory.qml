pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string percentage: " 0%"
    property string icon: " "

    Process {
        id: memoryProc
        command: ["sh", "-c", "awk '/^MemTotal/ { total=$2 } /^MemAvailable/ { avail=$2 } END { printf \"%.d%%\", 100 * (total - avail) / total }' /proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var percent = parseInt(this.text.trim())
                root.percentage = root.icon + this.text
            }
        }
    }
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: memoryProc.running = true
    }
}
