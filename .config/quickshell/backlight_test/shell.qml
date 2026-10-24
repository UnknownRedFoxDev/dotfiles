import Quickshell
import QtQuick
import "modules/bar"

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
}
