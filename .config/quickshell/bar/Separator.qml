import QtQuick

Text {
    required property string separator
    required property string fgColor
    required property string bgColor
    required property int fontSize

    property string fontFamily: "FiraCode Nerd Font"

    text: separator
    color: fgColor
    font.family: fontFamily
    font.pixelSize: fontSize
    Rectangle {
        anchors.fill: parent
        color: bgColor
        z: -1
    }
}
