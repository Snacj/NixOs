import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

// Volume module. Scroll to adjust, middle click to mute, click for a panel
// with the level, a mute toggle and the list of outputs to switch between.
Item {
    id: root

    // Passed to the popup so clicking another bar module swaps panels instead
    // of only dismissing this one.
    required property var barWindow

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property bool muted: root.sink?.audio?.muted ?? false

    // Every sink the machine can output to, minus per-application streams.
    readonly property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream)

    implicitWidth: module.implicitWidth
    implicitHeight: Theme.barHeight

    function label(node) {
        return node?.description || node?.nickname || node?.name || "unknown";
    }

    function setVolume(value) {
        if (root.sink?.audio)
            root.sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (root.sink?.audio)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    // Keeps the volume/mute properties of the default sink and of every sink
    // listed in the panel live.
    PwObjectTracker {
        objects: root.sinks.concat(root.sink ? [root.sink] : [])
    }

    Process {
        id: mixer
        command: ["pavucontrol"]
    }

    BarModule {
        id: module

        interactive: true
        expanded: popup.open
        text: root.muted ? "vol muted" : "vol " + Math.round(root.volume * 100) + "%"
        textColor: root.muted ? Theme.dim : Theme.module
        tooltipText: root.label(root.sink)

        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.toggleMute();
            else
                popup.open = !popup.open;
        }

        onWheel: event => root.setVolume(root.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
    }

    Popup {
        id: popup

        anchorItem: module
        passthroughWindows: [root.barWindow]

        Column {
            width: Theme.panelWidth
            spacing: 8

            Item {
                width: parent.width
                height: outputHeading.implicitHeight

                PopupHeading {
                    id: outputHeading
                    anchors.left: parent.left
                    text: "OUTPUT"
                }

                Text {
                    anchors.right: parent.right
                    text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
                    color: root.muted ? Theme.dim : Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Item {
                width: parent.width
                height: Theme.rowHeight

                Slider {
                    id: slider
                    anchors {
                        left: parent.left
                        right: muteButton.left
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    value: root.volume
                    fillColor: root.muted ? Theme.dim : Theme.accent
                    onMoved: value => root.setVolume(value)
                }

                MouseArea {
                    id: muteButton
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    implicitWidth: muteLabel.implicitWidth
                    implicitHeight: Theme.rowHeight
                    hoverEnabled: true

                    onClicked: root.toggleMute()

                    Text {
                        id: muteLabel
                        anchors.centerIn: parent
                        text: root.muted ? "unmute" : "mute"
                        color: muteButton.containsMouse ? Theme.foreground : Theme.dim
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

            PopupHeading {
                text: "DEVICES"
            }

            Column {
                width: parent.width

                Repeater {
                    model: root.sinks

                    PopupRow {
                        id: sinkRow

                        required property var modelData

                        implicitWidth: Theme.panelWidth
                        selected: sinkRow.modelData === root.sink

                        onClicked: Pipewire.preferredDefaultAudioSink = sinkRow.modelData

                        Text {
                            anchors { left: parent.left; right: parent.right }
                            text: root.label(sinkRow.modelData)
                            elide: Text.ElideRight
                            color: sinkRow.selected ? Theme.accent
                                 : sinkRow.containsMouse ? Theme.foreground
                                 : Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            PopupRow {
                id: mixerRow

                onClicked: {
                    mixer.running = true;
                    popup.open = false;
                }

                Text {
                    anchors.left: parent.left
                    text: "open pavucontrol"
                    color: mixerRow.containsMouse ? Theme.foreground : Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}
