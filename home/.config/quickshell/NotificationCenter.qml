import Quickshell
import QtQuick

// Notification history. The bar module carries the unread count; the panel
// lists what has arrived and can silence or clear it.
Item {
    id: root

    required property var barWindow

    readonly property int listHeight: 300

    implicitWidth: module.implicitWidth
    implicitHeight: Theme.barHeight

    BarModule {
        id: module

        interactive: true
        expanded: popup.open

        text: Notifications.doNotDisturb ? "dnd"
            : Notifications.unread > 0 ? "notif " + Notifications.unread
            : "notif"

        textColor: Notifications.doNotDisturb ? Theme.dim
                 : Notifications.unread > 0 ? Theme.accent
                 : Theme.module

        tooltipText: Notifications.doNotDisturb ? "do not disturb" : "notification history"

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                Notifications.doNotDisturb = !Notifications.doNotDisturb;
            else
                popup.open = !popup.open;
        }
    }

    Popup {
        id: popup

        anchorItem: module
        passthroughWindows: [root.barWindow]

        onOpenChanged: if (popup.open) Notifications.markRead()

        Column {
            width: Theme.panelWidth + 60
            spacing: 8

            Item {
                width: parent.width
                height: notifHeading.implicitHeight

                PopupHeading {
                    id: notifHeading
                    anchors.left: parent.left
                    text: "NOTIFICATIONS"
                }

                MouseArea {
                    id: dndButton
                    anchors.right: parent.right
                    implicitWidth: dndLabel.implicitWidth
                    implicitHeight: dndLabel.implicitHeight
                    hoverEnabled: true

                    onClicked: Notifications.doNotDisturb = !Notifications.doNotDisturb

                    Text {
                        id: dndLabel
                        text: Notifications.doNotDisturb ? "silenced" : "silence"
                        color: Notifications.doNotDisturb ? Theme.accent
                             : dndButton.containsMouse ? Theme.foreground
                             : Theme.dim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                visible: Notifications.history.length === 0
                text: "nothing yet"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            Item {
                width: parent.width
                height: Math.min(root.listHeight, list.contentHeight)
                visible: Notifications.history.length > 0

                Flickable {
                    id: list

                    anchors.fill: parent
                    contentHeight: entries.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: entries
                        width: list.width

                        Repeater {
                            model: Notifications.history

                            PopupRow {
                                id: entry

                                required property var modelData

                                implicitWidth: entries.width
                                contentPadding: 6

                                // Nothing to activate once a notification has
                                // been closed, so a click just marks it read.
                                onClicked: Notifications.markRead()

                                Column {
                                    anchors { left: parent.left; right: parent.right }
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: Qt.formatDateTime(entry.modelData.time, "HH:mm")
                                            + "  " + (entry.modelData.appName || "notification")
                                        elide: Text.ElideRight
                                        color: Notifications.urgencyColor(entry.modelData.urgency)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                    }

                                    Text {
                                        width: parent.width
                                        text: entry.modelData.summary
                                        elide: Text.ElideRight
                                        color: entry.containsMouse ? Theme.foreground : Theme.dim
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                    }
                                }
                            }
                        }
                    }
                }

                // Thin scroll indicator, only while there is more than fits.
                Rectangle {
                    anchors { right: parent.right; rightMargin: 1 }
                    width: 2
                    height: parent.height * Math.min(1, list.height / Math.max(list.contentHeight, 1))
                    y: (list.contentY / Math.max(list.contentHeight, 1)) * parent.height
                    color: Theme.borderStrong
                    visible: list.contentHeight > list.height
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                visible: Notifications.history.length > 0
            }

            PopupRow {
                id: clearRow

                implicitWidth: Theme.panelWidth + 60
                visible: Notifications.history.length > 0

                onClicked: {
                    Notifications.dismissAll();
                    Notifications.clearHistory();
                    popup.open = false;
                }

                Text {
                    anchors.left: parent.left
                    text: "clear history"
                    color: clearRow.containsMouse ? Theme.foreground : Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}
