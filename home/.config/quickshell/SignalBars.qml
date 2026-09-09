import QtQuick

// Four-segment signal meter. Reads faster than a percentage in a list, and
// stays legible at the small sizes the panel uses.
Item {
    id: root

    property real strength: 0   // 0..1
    property color activeColor: Theme.foreground
    property color inactiveColor: Theme.border

    readonly property int filled: root.strength >= 0.75 ? 4
                                : root.strength >= 0.5 ? 3
                                : root.strength >= 0.25 ? 2
                                : root.strength > 0 ? 1
                                : 0

    implicitWidth: 13
    implicitHeight: 10

    Row {
        anchors.bottom: parent.bottom
        spacing: 1

        Repeater {
            model: 4

            Rectangle {
                required property int index

                width: 2
                height: 3 + index * 2.3
                anchors.bottom: parent.bottom
                color: index < root.filled ? root.activeColor : root.inactiveColor

                Behavior on color {
                    ColorAnimation { duration: Theme.durNormal }
                }
            }
        }
    }
}
