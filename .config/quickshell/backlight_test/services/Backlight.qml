pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Reference to the /sys/class/backlight/intel_backlight
    property string device: "intel_backlight"

    property int maxBrightness: 1
    property int brightness: 0

    readonly property real ratio: root.maxBrightness > 0 ? root.brightness / root.maxBrightness : 0
    readonly property real percent: 100 * Math.pow(Math.max(ratio, 0), 1 / 2.2)
    readonly property int iconIndex: {
        if (root.percent <= 0)    return 0;
        if (root.percent <= 12.5) return 1;
        if (root.percent <= 25)   return 2;
        if (root.percent <= 37.5) return 3;
        if (root.percent <= 50)   return 4;
        if (root.percent <= 62.5) return 5;
        if (root.percent <= 75)   return 6;
        if (root.percent <= 87.5) return 7;
        if (root.percent <= 100)  return 8;
        return 4;
    }

    // Option A: If using Freedesktop / system icon theme names
    readonly property string iconName: [
        "", "", "", "", "", "", "", "", ""
    ][root.iconIndex]

    function setPercent(p) {
        if (root.maxBrightness <= 1) {
            console.log("backlight: max_brightness unknown, refusing write, reloading");
            maxFile.reload();
            brightnessFile.reload();
            return;
        }
        const clamped = Math.max(0, Math.min(100, p));
        const raw = clamped <= 0 ? 0 : Math.max(1, Math.round(root.maxBrightness * Math.pow(clamped / 100, 2.2)));

        console.log(`backlight: setPercent(${p}) -> raw ${raw}/${root.maxBrightness}`);

        root.pendingRaw = raw;
        setter.running = true;

        // a possible race-condition with uevent being read?
        root.brightness = raw;
    }

    function step(dt) {
        setPercent(root.percent + dt)
    }

    property int pendingRaw: 0

    // Re-reads /sys/class/backlight/intel_backlight/brightness
    function reload() {
        brightnessFile.reload();
    }

    FileView {
        id: maxFile
        path: `/sys/class/backlight/${root.device}/max_brightness`
        watchChanges: false // Why read the max value more than once?
        onTextChanged: {
            const v = parseInt(this.text().trim());
            if (v > 0) root.maxBrightness = v;
        }
    }

    FileView {
        id: brightnessFile
        path: `/sys/class/backlight/${root.device}/brightness`
        watchChanges: false // it doesn't send inotify events so it's useless
        onLoaded: {
            const v = parseInt(this.text().trim());
            if (v >= 0) root.brightness = v;
        }
        onTextChanged: {
            const v = parseInt(this.text().trim());
            if (v >= 0) root.brightness = v;
        }
    }

    // the fs (sysfs) doesn't emit any inotify when the brightness file changes.
    // however, the kernel emits a uevent instead: listen on the udev link and
    // re-read the file whenever the backlight's value is cahnged
    Process {
        id: udevMonitor
        command: ["udevadm", "monitor", "--kernel", "--subsystem-match=backlight"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (line.includes("backlight") && line.includes("change")) {
                    root.reload();
                }
            }
        }
    }

    // Set the brightness internal value with brightnessctl
    Process {
        id: setter
        command: ["brightnessctl", "-d", root.device, "s", `${root.pendingRaw}`]
    }

    Component.onCompleted: root.reload()
}
