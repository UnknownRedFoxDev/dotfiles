pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string timeDate: {
        Qt.formatDateTime(clock.date, " ddd d MMM")
    }

    readonly property string timeClock: {
        Qt.formatDateTime(clock.date, "HH:mm")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
