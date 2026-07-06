import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Hyprland

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            property string dimBlack: "#191726"
            property string dimWhite: "#696580"
            property string brightWhite: "#CDCBE0"
            color: dimBlack
            implicitHeight: 25

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: -1

                // ------------------------- CPU -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimWhite
                    bgColor: dimBlack
                    textDisplay: CpuPercentage.loadText
                }

                Separator {
                    separator: "  "
                    fgColor: dimWhite
                    bgColor: dimBlack
                    fontSize: 21
                }

                // ------------------------- Memory -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimWhite
                    bgColor: dimBlack
                    textDisplay: Memory.percentage
                }

                Separator {
                    separator: "  "
                    fgColor: "#696580"
                    bgColor: "#191726"
                    fontSize: 21
                }

                // ------------------------- Temperature -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimWhite
                    bgColor: dimBlack
                    textDisplay: Temperature.degree
                }

                Separator {
                    separator: "  "
                    fgColor: "#696580"
                    bgColor: "#191726"
                    fontSize: 21
                }

                // ------------------------- Battery -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimWhite
                    bgColor: dimBlack
                    textDisplay: Battery.percentage
                }

                Separator {
                    separator: " "
                    fgColor: "#CDCBE0"
                    bgColor: "#191726"
                    fontSize: 21
                }

                // ------------------------- Time (date) -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimBlack
                    bgColor: brightWhite
                    textDisplay: Time.timeDate
                }

                Separator {
                    separator: "  "
                    fgColor: "#191726"
                    bgColor: "#CDCBE0"
                    fontSize: 21
                }

                // ------------------------- Time (clock) -------------------------
                ComponentText {
                    barHeight: parent.height
                    textColor: dimBlack
                    bgColor: brightWhite
                    textDisplay: Time.timeClock
                }

                Separator {
                    separator: " "
                    fgColor: "#2B4052"
                    bgColor: "#CDCBE0"
                    fontSize: 21
                }


                // ------------------------- Audio -------------------------
                Audio {
                    id: audioModule
                }

                Separator {
                    separator: "  "
                    fgColor: "#CDCBE0"
                    bgColor: "#2B4052"
                    fontSize: 21
                }

                // ------------------------- Backlight -------------------------
                Backlight {
                    id: blightModule
                }

                Separator {
                    separator: " "
                    fgColor: "#569FBA"
                    bgColor: "#2B4052"
                    fontSize: 21
                }

                Button {
                    id: button
                    Text {
                        id: buttonText
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                        text: ""
                        color: "#191726"
                    }
                    background: Rectangle {
                        implicitWidth: 28
                        implicitHeight: 25
                        color: "#569FBA"
                    }
                    Process {
                        id: buttonEvent
                        command: "wlogout"
                        running: false
                    }
                    onClicked: buttonEvent.running = true;
                }
            }

            // ------------------------- LEFT COLUMN -------------------------
            // , 

            Row {
                spacing: -1
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                WorkspacesDisplay {
                    monitor: bar.hyprlandMonitor
                    persistentWorkspaces: [1, 2, 3, 4, 5]
                }
                Separator {
                    separator: " "
                    fgColor: "#2B4052"
                    bgColor: dimBlack
                    fontSize: 21
                }
                FocusedWindow {
                }
            }
        }
    }
}
