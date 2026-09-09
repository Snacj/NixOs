import QtQuick

// Hairline between modules in the right-hand group. Short and low contrast:
// enough to separate readings at a glance without adding visual weight.
Item {
    implicitWidth: 1
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: Math.round(Theme.barHeight * 0.45)
        color: Theme.border
    }
}
