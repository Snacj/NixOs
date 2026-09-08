import QtQuick

// One text module in the bar: a label with waybar's 8px side padding, hover
// colour and an optional tooltip.
MouseArea {
    id: root

    property string text: ""
    property color textColor: Theme.module
    property color hoverColor: root.textColor
    property string tooltipText: ""
    property int horizontalPadding: Theme.modulePadding

    implicitWidth: label.implicitWidth + root.horizontalPadding * 2
    height: Theme.barHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.containsMouse ? root.hoverColor : root.textColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    Tooltip {
        target: root
        active: root.containsMouse && root.tooltipText !== ""

        TooltipText {
            text: root.tooltipText
        }
    }
}
