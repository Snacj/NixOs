import Quickshell
import QtQuick

// Hover hint above a bar item. Kept for read-only detail; anything you can act
// on gets a Popup instead.
PopupWindow {
    id: root

    required property Item target
    property bool active: false
    default property alias content: body.data

    anchor {
        item: root.target
        edges: Edges.Top
        gravity: Edges.Top
        margins.bottom: Theme.popupGap
        adjustment: PopupAdjustment.SlideX
    }

    implicitWidth: body.implicitWidth + 20
    implicitHeight: body.implicitHeight + 12
    color: "transparent"
    visible: root.active

    Rectangle {
        anchors.fill: parent
        color: Theme.popup
        border.color: Theme.borderStrong
        border.width: 1

        Item {
            id: body
            anchors.centerIn: parent
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
