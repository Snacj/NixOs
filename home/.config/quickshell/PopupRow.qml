import QtQuick

// A selectable line inside a panel, e.g. one wifi network or one audio sink.
// Selection is shown by an accent rule on the leading edge rather than a fill,
// which keeps a long list quiet.
//
// The row spans the panel width; content is laid out inside `body`, which is
// already inset past the selection rule.
MouseArea {
    id: root

    property bool selected: false
    property int contentPadding: 8

    default property alias content: body.data

    implicitWidth: Theme.panelWidth
    implicitHeight: Math.max(Theme.rowHeight, body.childrenRect.height + 8)
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        color: root.containsMouse ? Theme.popupRaised : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 3
        color: Theme.accent
        opacity: root.selected ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durNormal }
        }
    }

    Item {
        id: body
        anchors {
            left: parent.left
            leftMargin: root.contentPadding + 3
            right: parent.right
            rightMargin: root.contentPadding
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height
    }
}
