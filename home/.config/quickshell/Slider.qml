import QtQuick

// Flat horizontal slider. No handle knob: the fill edge is the handle, which
// suits the square-cornered look of the rest of the shell.
Item {
    id: root

    property real value: 0        // 0..1
    property color fillColor: Theme.accent
    signal moved(real value)

    implicitWidth: 170
    implicitHeight: 14

    function valueAt(x) {
        return Math.max(0, Math.min(1, x / Math.max(root.width, 1)));
    }

    Rectangle {
        id: track
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        height: 4
        color: Theme.border

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: parent.width * Math.max(0, Math.min(1, root.value))
            color: root.fillColor
        }
    }

    // The leading edge of the fill, extended so the exact level stays readable
    // at low volumes.
    Rectangle {
        x: Math.round(root.width * Math.max(0, Math.min(1, root.value))) - 1
        anchors { top: parent.top; bottom: parent.bottom }
        width: 2
        color: root.fillColor
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onPressed: event => root.moved(root.valueAt(event.x))
        onPositionChanged: event => {
            if (pressed)
                root.moved(root.valueAt(event.x));
        }
        onWheel: event => {
            const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
            root.moved(Math.max(0, Math.min(1, root.value + step)));
        }
    }
}
