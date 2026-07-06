import QtQuick
import Quickshell

Rectangle {
    required property int barHeight
    required property string textColor
    required property string bgColor
    required property string textDisplay
    implicitWidth: displayedText.implicitWidth

    height: barHeight
    color: bgColor
    Text {
        id: displayedText
        topPadding: 2
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 18
        font.weight: 500
        color: textColor
        text: textDisplay
    }
}
