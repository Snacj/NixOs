import Quickshell
import Quickshell.Networking
import QtQuick

// Network module, backed by Quickshell's NetworkManager bindings rather than
// by polling nmcli. Click for a panel that lists nearby networks and can
// connect to them, including asking for a passphrase.
Item {
    id: root

    required property var barWindow

    readonly property var devices: Networking.devices?.values ?? []
    readonly property var wifiDevice: root.devices.find(device => device.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: root.devices.find(device => device.type === DeviceType.Wired) ?? null

    readonly property var activeWifi: root.wifiDevice?.networks?.values?.find(network => network.connected) ?? null
    readonly property bool wiredUp: root.wiredDevice?.connected ?? false

    // Strongest first, so the network you want is normally at the top.
    readonly property var visibleNetworks: (root.wifiDevice?.networks?.values ?? [])
        .filter(network => network.name !== "")
        .slice()
        .sort((a, b) => b.signalStrength - a.signalStrength)

    // NetworkManager reports Portal/Limited when a link is up but has no
    // usable route; worth surfacing, since the SSID alone looks fine.
    readonly property bool degraded: (root.wiredUp || root.activeWifi !== null)
        && Networking.connectivity !== NetworkConnectivity.Full
        && Networking.connectivity !== NetworkConnectivity.Unknown

    readonly property bool connected: root.wiredUp || root.activeWifi !== null

    // What the link actually is, rather than the device MAC that
    // NetworkDevice.address reports.
    readonly property string detail: {
        if (root.wiredUp) {
            const speed = root.wiredDevice?.linkSpeed ?? 0;
            return speed > 0 ? "ethernet  " + speed + " Mb/s" : "ethernet";
        }
        if (root.activeWifi !== null)
            return root.activeWifi.name + "  " + Math.round(root.activeWifi.signalStrength * 100) + "%";
        return "disconnected";
    }

    implicitWidth: module.implicitWidth
    implicitHeight: Theme.barHeight

    // Scanning costs power, so only scan while the panel is actually open.
    onWifiDeviceChanged: if (root.wifiDevice) root.wifiDevice.scannerEnabled = popup.open

    function secured(network) {
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Owe;
    }

    BarModule {
        id: module

        interactive: true
        expanded: popup.open

        text: root.wiredUp ? "eth"
            : root.activeWifi !== null ? root.activeWifi.name
            : Networking.wifiEnabled ? "offline"
            : "wifi off"

        textColor: root.degraded ? Theme.critical
                 : root.connected ? Theme.module
                 : Theme.dim

        tooltipText: root.degraded ? "connected, no internet" : root.detail

        onClicked: popup.open = !popup.open
    }

    Popup {
        id: popup

        anchorItem: module
        passthroughWindows: [root.barWindow]

        onOpenChanged: {
            if (root.wifiDevice)
                root.wifiDevice.scannerEnabled = popup.open;
            if (!popup.open)
                pskPrompt.network = null;
        }

        Column {
            width: Theme.panelWidth
            spacing: 8

            Item {
                width: parent.width
                height: netHeading.implicitHeight

                PopupHeading {
                    id: netHeading
                    anchors.left: parent.left
                    text: "NETWORK"
                }

                MouseArea {
                    anchors.right: parent.right
                    implicitWidth: wifiToggle.implicitWidth
                    implicitHeight: wifiToggle.implicitHeight
                    hoverEnabled: true
                    enabled: Networking.wifiHardwareEnabled

                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled

                    Text {
                        id: wifiToggle
                        text: !Networking.wifiHardwareEnabled ? "wifi blocked"
                            : Networking.wifiEnabled ? "wifi on" : "wifi off"
                        color: !Networking.wifiHardwareEnabled ? Theme.critical
                             : Networking.wifiEnabled ? Theme.accent : Theme.dim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // Current connection, when there is one worth describing.
            Text {
                width: parent.width
                visible: root.connected
                elide: Text.ElideRight
                text: root.detail
                color: root.degraded ? Theme.critical : Theme.good
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                visible: Networking.wifiEnabled && root.wifiDevice !== null
            }

            PopupHeading {
                visible: Networking.wifiEnabled && root.wifiDevice !== null
                text: "NEARBY"
            }

            Text {
                visible: Networking.wifiEnabled && root.wifiDevice !== null
                    && root.visibleNetworks.length === 0
                text: "scanning…"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            // Capped so a busy area cannot grow the panel past the screen.
            Column {
                width: parent.width
                visible: Networking.wifiEnabled

                Repeater {
                    model: root.visibleNetworks.slice(0, 8)

                    PopupRow {
                        id: netRow

                        required property var modelData

                        implicitWidth: Theme.panelWidth
                        selected: netRow.modelData.connected
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: event => {
                            const network = netRow.modelData;

                            if (event.button === Qt.RightButton) {
                                if (network.known)
                                    network.forget();
                                return;
                            }

                            if (network.connected)
                                network.disconnect();
                            else if (network.known || !root.secured(network))
                                network.connect();
                            else
                                pskPrompt.network = network;
                        }

                        SignalBars {
                            id: bars
                            anchors { left: parent.left; verticalCenter: name.verticalCenter }
                            strength: netRow.modelData.signalStrength
                            activeColor: netRow.selected ? Theme.accent : Theme.dim
                        }

                        Text {
                            id: name
                            anchors {
                                left: bars.right
                                leftMargin: 8
                                right: stateLabel.left
                                rightMargin: 6
                            }
                            text: netRow.modelData.name
                                + (root.secured(netRow.modelData) ? "" : "  (open)")
                            elide: Text.ElideRight
                            color: netRow.selected ? Theme.accent
                                 : netRow.containsMouse ? Theme.foreground
                                 : Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Text {
                            id: stateLabel
                            anchors { right: parent.right; verticalCenter: name.verticalCenter }
                            text: netRow.modelData.stateChanging ? "…"
                                : netRow.modelData.connected ? "✓"
                                : netRow.modelData.known ? "saved"
                                : ""
                            color: netRow.selected ? Theme.accent : Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            // Passphrase entry, shown in place when a secured network that has
            // no saved connection is picked.
            Column {
                id: pskPrompt

                property var network: null

                width: parent.width
                spacing: 6
                visible: pskPrompt.network !== null

                onNetworkChanged: {
                    pskField.text = "";
                    if (pskPrompt.network !== null)
                        pskField.forceActiveFocus();
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                PopupHeading {
                    text: "PASSPHRASE FOR " + (pskPrompt.network?.name ?? "")
                }

                Rectangle {
                    width: parent.width
                    height: Theme.rowHeight
                    color: Theme.popupRaised
                    border.color: pskField.activeFocus ? Theme.accent : Theme.border
                    border.width: 1

                    TextInput {
                        id: pskField
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Theme.foreground
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.popup
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall

                        onAccepted: {
                            if (pskPrompt.network !== null && text !== "") {
                                pskPrompt.network.connectWithPsk(text);
                                pskPrompt.network = null;
                            }
                        }

                        Keys.onEscapePressed: pskPrompt.network = null
                    }
                }
            }
        }
    }
}
