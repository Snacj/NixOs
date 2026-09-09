import Quickshell.Widgets
import QtQuick

// One notification, as shown in the toast stack.
//
// Hovering pauses the countdown, so a notification cannot expire out from
// under the pointer while it is being read.
Rectangle {
    id: root

    required property var notification

    readonly property int timeout: Notifications.timeoutFor(root.notification)
    readonly property color urgency: Notifications.urgencyColor(root.notification.urgency)
    readonly property bool hasImage: (root.notification.image ?? "") !== ""

    // 0 while entering, 1 once in place.
    property real progress: 0

    implicitWidth: 340
    implicitHeight: layout.implicitHeight + 20

    color: Theme.popup
    border.color: Theme.borderStrong
    border.width: 1

    opacity: root.progress
    // Translated rather than moved: this card is laid out by a Column, and a
    // positioner overwrites a child's x.
    transform: Translate { x: (1 - root.progress) * 24 }

    Component.onCompleted: root.progress = 1

    Behavior on progress {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutQuad }
    }

    // Urgency rule on the leading edge, echoing the selection rule in panels.
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        anchors.margins: 1
        width: 3
        color: root.urgency
    }

    // Remaining time, drawn along the bottom edge. Freezes on hover with the
    // timer, which makes the pause visible instead of merely felt.
    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; leftMargin: 1; bottomMargin: 1 }
        height: 2
        width: (root.width - 2) * (expiry.running || mouse.containsMouse
            ? Math.max(0, expiry.remaining / Math.max(root.timeout, 1)) : 0)
        color: root.urgency
        opacity: 0.45
        visible: root.timeout > 0
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: event => {
            if (event.button === Qt.LeftButton && root.notification.actions.length > 0)
                root.notification.actions[0].invoke();
            else
                root.notification.dismiss();
        }
    }

    // Counts down in steps so the progress rule can be drawn, and holds while
    // hovered.
    Timer {
        id: expiry

        property int remaining: root.timeout

        interval: 50
        repeat: true
        running: root.timeout > 0 && !mouse.containsMouse

        onTriggered: {
            expiry.remaining -= expiry.interval;
            if (expiry.remaining <= 0)
                root.notification.expire();
        }
    }

    Column {
        id: layout

        anchors {
            left: parent.left
            leftMargin: 14
            right: parent.right
            rightMargin: 12
            top: parent.top
            topMargin: 10
        }
        spacing: 5

        Item {
            width: parent.width
            height: appName.implicitHeight

            IconImage {
                id: appIconImage
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                implicitSize: Theme.fontSizeSmall + 2
                source: root.notification.appIcon ?? ""
                visible: (root.notification.appIcon ?? "") !== ""
            }

            Text {
                id: appName
                anchors {
                    left: appIconImage.visible ? appIconImage.right : parent.left
                    leftMargin: appIconImage.visible ? 6 : 0
                    right: closeHint.left
                    rightMargin: 6
                }
                text: root.notification.appName !== "" ? root.notification.appName : "notification"
                elide: Text.ElideRight
                color: root.urgency
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            Text {
                id: closeHint
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: mouse.containsMouse ? "dismiss" : Qt.formatDateTime(new Date(), "HH:mm")
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Image {
                id: preview
                width: root.hasImage ? 40 : 0
                height: root.hasImage ? 40 : 0
                visible: root.hasImage
                source: root.notification.image ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 80
                sourceSize.height: 80
            }

            Column {
                width: parent.width - (root.hasImage ? preview.width + parent.spacing : 0)
                spacing: 3

                Text {
                    width: parent.width
                    text: root.notification.summary
                    elide: Text.ElideRight
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    width: parent.width
                    visible: root.notification.body !== ""
                    text: root.notification.body
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 4
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Row {
            spacing: 6
            visible: root.notification.actions.length > 0

            Repeater {
                model: root.notification.actions

                MouseArea {
                    id: action

                    required property var modelData

                    implicitWidth: actionLabel.implicitWidth + 16
                    implicitHeight: 22
                    hoverEnabled: true

                    onClicked: action.modelData.invoke()

                    Rectangle {
                        anchors.fill: parent
                        color: action.containsMouse ? Theme.popupRaised : "transparent"
                        border.color: action.containsMouse ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: Theme.durFast }
                        }
                    }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: action.modelData.text
                        color: action.containsMouse ? Theme.foreground : Theme.dim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }
        }
    }
}
