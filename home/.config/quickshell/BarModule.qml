import QtQuick

// One module in the bar: a label, an optional hover tooltip, and an optional
// click-to-open panel.
//
// Modules that open a panel get a hover fill and an accent rule along the top
// edge while open, so it is obvious which module a panel belongs to.
MouseArea {
    id: root

    property string text: ""
    property color textColor: Theme.module
    property color hoverColor: Theme.dimHover
    property string tooltipText: ""

    // Set by the owner when this module's panel is showing.
    property bool expanded: false
    // Draw the hover fill. Off for purely informational modules.
    property bool interactive: false

    property int horizontalPadding: Theme.modulePadding

    implicitWidth: label.implicitWidth + root.horizontalPadding * 2
    height: Theme.barHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Rectangle {
        anchors.fill: parent
        color: root.expanded ? Theme.surfaceActive
             : root.interactive && root.containsMouse ? Theme.surface
             : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.durNormal }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.expanded ? Theme.accent
             : root.containsMouse ? root.hoverColor
             : root.textColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize

        Behavior on color {
            ColorAnimation { duration: Theme.durNormal }
        }
    }

    // Along the top edge: the edge facing the screen, so the rule points at
    // the panel that opens above it.
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: Theme.indicatorHeight
        color: Theme.accent
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durNormal }
        }
    }

    Tooltip {
        target: root
        active: root.containsMouse && !root.expanded && root.tooltipText !== ""

        TooltipText {
            text: root.tooltipText
        }
    }
}
