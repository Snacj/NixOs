import Quickshell
import QtQuick

// Popup shown above a bar module while it is hovered, styled like the old
// GTK waybar tooltip.
PopupWindow {
    id: root

    required property Item target
    property bool active: false
    default property alias content: body.data

    anchor {
        item: root.target
        edges: Edges.Top
        gravity: Edges.Top
        margins.bottom: 4
    }

    implicitWidth: body.implicitWidth + 18
    implicitHeight: body.implicitHeight + 12
    color: "transparent"
    visible: root.active

    Rectangle {
        anchors.fill: parent
        color: Theme.tooltipBackground
        border.color: Theme.border
        border.width: 1

        Item {
            id: body
            anchors.centerIn: parent
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
