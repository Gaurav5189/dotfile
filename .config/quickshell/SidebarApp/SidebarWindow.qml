import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import qs.CustomTheme

PanelWindow {
    id: root

    // --- WAYLAND CONFIGURATION ---
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore
    WlrLayershell.namespace: "quickshell:sidebar"

    surfaceFormat {
        opaque: false
    }

    implicitWidth: 420 // 380 + 40
    color: "transparent"

    property bool isHyprlandSettingsInstalled: false

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins {
        top: 52
        bottom: 0
    }

    // --- CLICK OUTSIDE TO CLOSE (Native Hyprland) ---
    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ESCAPE KEY LISTENER ---
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ANIMATION LOGIC ---
    property bool isOpen: false
    visible: isOpen || slideAnim.running

    margins { right: root.currentMargin }
    property real currentMargin: isOpen ? 0 : -470

    Behavior on currentMargin {
        NumberAnimation {
            id: slideAnim
            duration: 350
            easing.type: Easing.OutQuint
        }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
        function isOpen(): bool { return root.isOpen }
    }

    Process {
        command: ["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-command-exists hyprmod"]
        running: root.visible

        stdout: StdioCollector {
            onStreamFinished: {
                console.log(this.text.trim())
                root.isHyprlandSettingsInstalled = (this.text.trim() === "0")
            }
        }
    }

    // --- REUSABLE COMPONENTS ---

    component ML4WCard: Rectangle {
        Layout.fillWidth: true
        implicitHeight: layout.implicitHeight + 30
        radius: 20
        color: Qt.rgba(0.15, 0.15, 0.15, 0.8) // Darker but more opaque for contrast
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.1) // Subtle white border to define the cell
        border.width: 1

        default property alias content: layout.data

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
        }
    }

    component ML4WMenuItem: MenuItem {
        id: control
        contentItem: Text {
            text: control.text
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: control.highlighted ? Theme.background : Theme.primary
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 36
            color: control.highlighted ? Theme.primary : "transparent"
            radius: 4
        }
    }

    component ML4WButton: Button {
        Layout.fillWidth: true
        background: Rectangle {
            color: "transparent"
            border.color: Theme.primary
            border.width: 1
            radius: 10
        }
        contentItem: Text {
            text: parent.text
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: Theme.primary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            padding: 8
        }
    }

    component ML4WSwitch: Switch {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 48
        implicitHeight: 26
        indicator: Rectangle {
            implicitWidth: 48
            implicitHeight: 26
            radius: 13
            color: parent.checked ? Theme.primary : Theme.background
            border.color: Theme.primary
            border.width: 1
            Rectangle {
                x: parent.parent.checked ? parent.width - width - 2 : 2
                y: 2
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: parent.parent.checked ? Theme.background : Theme.on_primary
                Behavior on x { NumberAnimation { duration: 150 } }
            }
        }
    }

    component SettingsWheel: Button {
        implicitWidth: 28
        implicitHeight: 28
        background: Rectangle { color: "transparent" }
        contentItem: Item {
            Image {
                anchors.centerIn: parent
                source: "../shared/icons/settings.svg"
                width: 18
                height: 18
                sourceSize.width: 18
                sourceSize.height: 18
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Theme.primary
                }
            }
        }
    }

    // Supports text glyphs (iconTxt) for MPRIS controls and SVG files (iconSrc) for sidebar icons
    component ActionIcon: Button {
        property string iconTxt: ""
        property string iconSrc: ""
        implicitWidth: 28
        implicitHeight: 28
        background: Rectangle { color: "transparent" }
        contentItem: Item {
            Text {
                anchors.centerIn: parent
                text: iconTxt
                visible: iconSrc === ""
                color: Theme.primary
                font.family: "monospace"
                font.pixelSize: 18
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Image {
                anchors.centerIn: parent
                source: iconSrc
                width: 18
                height: 18
                sourceSize.width: 18
                sourceSize.height: 18
                visible: iconSrc !== ""
                fillMode: Image.PreserveAspectFit
                layer.enabled: iconSrc !== ""
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Theme.primary
                }
            }
        }
    }

    // ==========================================
    // MAIN PANEL BACKGROUND
    // ==========================================
    Item {
        anchors.fill: parent
        anchors.margins: 20

        RectangularShadow {
            id: shadow
            anchors.fill: mainBgRect
            radius: mainBgRect.radius
            blur: 15
            color: Qt.rgba(Theme.shadow.r, Theme.shadow.g, Theme.shadow.b, 0.4)
        }

        Rectangle {
            id: mainBgRect
            anchors.fill: parent
            radius: 10

            // Gradient border (outer) - subtle, translucent frosted-white edge
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(1.0, 1.0, 1.0, 0.22) }
                GradientStop { position: 1.0; color: Qt.rgba(1.0, 1.0, 1.0, 0.07) }
            }

            // Background fill (inner) - semi-transparent dark grey for frosted glass look
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: parent.radius - anchors.margins
                color: Qt.rgba(0.05, 0.05, 0.05, 0.6) // Slightly darker background to make cards pop
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // --- TOP BAR (Light/Dark, Screenshot & Color Picker) ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ActionIcon {
                    iconSrc: "../shared/icons/darklight.svg"
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-toggle-theme"])
                    }
                }

                Item { Layout.fillWidth: true }

                ActionIcon {
                    iconSrc: "../shared/icons/picker.svg"
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/settings/hyprpicker.sh"])
                    }
                }

                ActionIcon {
                    iconSrc: "../shared/icons/screenshot.svg"
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/screenshot.sh"])
                    }
                }
            }


            // --- WELCOME & SETTINGS ---
            ML4WCard {
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    ML4WButton {
                        text: "Welcome"
                        background: Rectangle { color: Qt.rgba(1,1,1,0.1); radius: 10 } // Increased opacity for visibility
                        onClicked: {
                            root.isOpen = false
                            Quickshell.execDetached(["bash", "-c", "qs ipc call welcome toggle"])
                        }
                    }
                    ML4WButton {
                        text: "Settings"
                        background: Rectangle { color: Qt.rgba(1,1,1,0.1); radius: 10 } // Increased opacity for visibility
                        onClicked: {
                            root.isOpen = false
                            Quickshell.execDetached(["bash", "-c", "qs -p " + Quickshell.env("HOME") + "/.local/share/ml4w-dotfiles-settings/quickshell ipc call settings toggle"])
                        }
                    }
                }
            }

            // --- SCROLLABLE CONTENT ---
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: mainContentColumn.implicitHeight // Tells ScrollView how tall the inner content truly is
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    contentItem: Rectangle {
                        implicitWidth: 6; radius: 3; color: Theme.primary
                        opacity: parent.pressed ? 1.0 : (parent.active ? 0.8 : 0.4)
                    }
                }

                ColumnLayout {
                    id: mainContentColumn
                    width: scrollView.width
                    spacing: 20

                    // --- SLIDERS (Loudness & Brightness) ---
                    ML4WCard {
                        // LOUDNESS SLIDER
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Image {
                                source: "../shared/icons/volume.svg"
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: Theme.primary
                                }
                            }

                            Slider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 50 // Default

                                Process {
                                    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            let val = parseInt(this.text.trim())
                                            if (!isNaN(val)) volumeSlider.value = val;
                                        }
                                    }
                                }

                                onMoved: {
                                    Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(value) + "%"])
                                }

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 24
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 12
                                    color: Qt.rgba(0.2, 0.2, 0.2, 0.8)

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Qt.rgba(0.4, 0.9, 0.6, 1.0)
                                        radius: 12
                                    }
                                }

                                handle: Item {}
                            }
                        }

                        // BRIGHTNESS SLIDER
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            Image {
                                source: "../shared/icons/brightness.svg"
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: Theme.primary
                                }
                            }

                            Slider {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                from: 10 // Guaranteed Minimum 10%
                                to: 100
                                value: 100

                                Process {
                                    command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(\"%\",\"\",$4); print $4}'"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            let val = parseInt(this.text.trim())
                                            if (!isNaN(val)) brightnessSlider.value = Math.max(10, val);
                                        }
                                    }
                                }

                                onMoved: {
                                    Quickshell.execDetached(["bash", "-c", "brightnessctl set " + Math.round(value) + "%"])
                                }

                                background: Rectangle {
                                    x: brightnessSlider.leftPadding
                                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 24
                                    width: brightnessSlider.availableWidth
                                    height: implicitHeight
                                    radius: 12
                                    color: Qt.rgba(0.2, 0.2, 0.2, 0.8)

                                    Rectangle {
                                        width: brightnessSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Qt.rgba(0.4, 0.9, 0.6, 1.0)
                                        radius: 12
                                    }
                                }

                                handle: Item {}
                            }
                        }
                    }


                    // --- STATUS BAR ---
                    ML4WCard {
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Status Bar"; color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: 16 }
                            Item { Layout.fillWidth: true }
                            ML4WSwitch {
                                id: statusbarSwitch
                                property bool ready: false
                                property string activeBar: "waybar"
                                Process {
                                    id: statusbarStateProc
                                    command: ["bash", "-c", "sb=$(tr -d '[:space:]' < ~/.config/ml4w/settings/statusbar 2>/dev/null); [ -n \"$sb\" ] || sb=waybar; if [ \"$sb\" = quickshell ]; then f=~/.config/ml4w-statusbar/statusbar.json; [ -f \"$f\" ] || f=~/.config/ml4w/settings/statusbar.json; grep -q '\"enabled\"[[:space:]]*:[[:space:]]*false' \"$f\" && s=0 || s=1; else test -f ~/.config/ml4w/settings/waybar-disabled && s=0 || s=1; fi; echo \"$sb $s\""]
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            let parts = this.text.trim().split(" ")
                                            statusbarSwitch.activeBar = parts[0]
                                            statusbarSwitch.checked = (parts[1] === "1")
                                            statusbarSwitch.ready = true
                                        }
                                    }
                                }
                                Timer {
                                    interval: 1000
                                    repeat: true
                                    running: root.isOpen
                                    triggeredOnStart: true
                                    onTriggered: statusbarStateProc.running = true
                                }
                                onClicked: {
                                    if (!ready) return;
                                    let cmd = activeBar === "quickshell"
                                        ? (checked ? "qs ipc call statusbar enable"
                                                   : "qs ipc call statusbar disable")
                                        : (checked ? "rm -f ~/.config/ml4w/settings/waybar-disabled; " + Quickshell.env("HOME") + "/.config/waybar/launch.sh"
                                                   : "touch ~/.config/ml4w/settings/waybar-disabled; " + Quickshell.env("HOME") + "/.config/waybar/launch.sh")
                                    Quickshell.execDetached(["bash", "-c", cmd])
                                }
                            }

                            SettingsWheel {
                                onClicked: statusbarMenu.open()
                                Menu {
                                    id: statusbarMenu
                                    y: parent.height
                                    implicitWidth: 220
                                    padding: 8

                                    property bool overrideExists: false
                                    Process {
                                        command: ["bash", "-c", "[ -f ~/.config/ml4w-statusbar/statusbar.json ] && echo 1 || echo 0"]
                                        running: root.isOpen
                                        stdout: StdioCollector {
                                            onStreamFinished: {
                                                statusbarMenu.overrideExists = (this.text.trim() === "1")
                                            }
                                        }
                                    }

                                    background: Rectangle { color: Theme.background; border.color: Theme.primary; border.width: 1; radius: 8 }
                                    ML4WMenuItem { text: "Reload Status Bar"; onClicked: {
                                            Quickshell.execDetached(["bash", "-c", "~/.config/ml4w/scripts/ml4w-reload-statusbar"])
                                        }
                                    }
                                    ML4WMenuItem {
                                        text: "Select Waybar Theme"
                                        visible: statusbarSwitch.activeBar === "waybar"
                                        height: visible ? implicitHeight : 0
                                        onClicked: {
                                            Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/waybar/themeswitcher.sh"])
                                        }
                                    }
                                    ML4WMenuItem {
                                        text: "Edit Quicklinks"
                                        visible: statusbarSwitch.activeBar === "waybar"
                                        height: visible ? implicitHeight : 0
                                        onClicked: {
                                            root.isOpen = false
                                            Quickshell.execDetached(["gnome-text-editor", Quickshell.env("HOME") + "/.config/ml4w/settings/waybar-quicklinks.json"])
                                        }
                                    }
                                    ML4WMenuItem {
                                        text: "Edit Settings"
                                        visible: statusbarMenu.overrideExists
                                        height: visible ? implicitHeight : 0
                                        onClicked: {
                                            root.isOpen = false
                                            Quickshell.execDetached(["bash", "-c", "f=~/.config/ml4w-statusbar/statusbar.json; [ -f \"$f\" ] || f=~/.config/ml4w/settings/statusbar.json; ~/.config/ml4w/settings/editor.sh \"$f\""])
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // --- GAMEMODE & FASTFETCH ---
                    ML4WCard {
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Gamemode"; color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: 16 }
                            Item { Layout.fillWidth: true }
                            ML4WSwitch {
                                id: gamemodeSwitch
                                property bool ready: false
                                Process {
                                    command: ["bash", "-c", "test -f ~/.config/ml4w/settings/gamemode-enabled && echo 0 || echo 1"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            gamemodeSwitch.checked = (this.text.trim() === "0")
                                            gamemodeSwitch.ready = true
                                        }
                                    }
                                }
                                onClicked: {
                                    if (!ready) return;
                                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/gamemode.sh"])
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Fastfetch"; color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: 16 }
                            Item { Layout.fillWidth: true }
                            ML4WSwitch {
                                id: fastfetchSwitch
                                property bool ready: false
                                Process {
                                    command: ["bash", "-c", "test -f ~/.config/ml4w/settings/hide-fastfetch && echo 1 || echo 0"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            fastfetchSwitch.checked = (this.text.trim() === "0")
                                            fastfetchSwitch.ready = true
                                        }
                                    }
                                }
                                onClicked: {
                                    if (!ready) return;
                                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-toggle-fastfetch"])
                                }
                            }
                        }
                    }

                    // --- QUICK SETTINGS (WIFI, BT, DND) ---
                    ML4WCard {
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            // WIFI
                            Item {
                                id: wifiBtn
                                Layout.fillWidth: true
                                implicitHeight: 56
                                property bool isActive: false
                                Process {
                                    command: ["bash", "-c", "nmcli radio wifi | grep -q 'enabled' && echo active || echo inactive"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            wifiBtn.isActive = (this.text.trim() === "active")
                                        }
                                    }
                                }
                                Rectangle {
                                    id: wifiBg
                                    anchors.centerIn: parent
                                    width: 52
                                    height: 52
                                    radius: width / 2
                                    color: wifiBtn.isActive ? Qt.rgba(0.4, 0.9, 0.6, 0.3) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "monospace"
                                        font.pixelSize: 22
                                        color: Theme.primary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton) {
                                            wifiBtn.isActive = !wifiBtn.isActive
                                            Quickshell.execDetached(["bash", "-c", "nmcli radio wifi | grep -q 'enabled' && nmcli radio wifi off || nmcli radio wifi on"])
                                        } else if (mouse.button === Qt.RightButton) {
                                            root.isOpen = false
                                            Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/settings/networkmanager.sh"])
                                        }
                                    }
                                }
                            }

                            // BLUETOOTH
                            Item {
                                id: btBtn
                                Layout.fillWidth: true
                                implicitHeight: 56
                                property bool isActive: false
                                Process {
                                    command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo active || echo inactive"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            btBtn.isActive = (this.text.trim() === "active")
                                        }
                                    }
                                }
                                Rectangle {
                                    id: btBg
                                    anchors.centerIn: parent
                                    width: 52
                                    height: 52
                                    radius: width / 2
                                    color: btBtn.isActive ? Qt.rgba(0.4, 0.9, 0.6, 0.3) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "monospace"
                                        font.pixelSize: 22
                                        color: Theme.primary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton) {
                                            btBtn.isActive = !btBtn.isActive
                                            Quickshell.execDetached(["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || (rfkill unblock bluetooth; sleep 0.1; bluetoothctl power on)"])
                                        } else if (mouse.button === Qt.RightButton) {
                                            root.isOpen = false
                                            Quickshell.execDetached(["blueman-manager"])
                                        }
                                    }
                                }
                            }

                            // DO NOT DISTURB (DND)
                            Item {
                                id: dndBtn
                                Layout.fillWidth: true
                                implicitHeight: 56
                                property bool isActive: false
                                Process {
                                    command: ["bash", "-c", "swaync-client -D | grep -q 'true' && echo active || echo inactive"]
                                    running: root.isOpen
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            dndBtn.isActive = (this.text.trim() === "active")
                                        }
                                    }
                                }
                                Rectangle {
                                    id: dndBg
                                    anchors.centerIn: parent
                                    width: 52
                                    height: 52
                                    radius: width / 2
                                    color: dndBtn.isActive ? Qt.rgba(0.4, 0.9, 0.6, 0.3) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "monospace"
                                        font.pixelSize: 22
                                        color: Theme.primary
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        dndBtn.isActive = !dndBtn.isActive
                                        Quickshell.execDetached(["swaync-client", "-d", "-sw"])
                                    }
                                }
                            }
                        }
                    }


                    // --- WALLPAPER ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Wallpaper"; color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true }
                        ActionIcon {
                            iconSrc: "../shared/icons/wallpaper.svg"
                            onClicked: {
                                root.isOpen = false
                                Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/scripts/ml4w-wallpaper-app"])
                            }
                        }
                    }

                    // --- THEME ---
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Theme"; color: Theme.primary; font.family: Theme.fontFamily; font.pixelSize: 16 }
                        Item { Layout.fillWidth: true }
                        ActionIcon {
                            iconSrc: "../shared/icons/theme.svg"
                            onClicked: {
                                root.isOpen = false
                                Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/ml4w/themes/themes.sh"])
                            }
                        }
                        SettingsWheel {
                            onClicked: themeMenu.open()
                            Menu {
                                id: themeMenu
                                y: parent.height

                                implicitWidth: 220
                                padding: 8

                                background: Rectangle { color: Theme.background; border.color: Theme.primary; border.width: 1; radius: 8 }
                                ML4WMenuItem { text: "Set GTK Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["nwg-look"])
                                    }
                                }
                                ML4WMenuItem { text: "Set QT Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["qt6ct"])
                                    }
                                }
                                ML4WMenuItem { text: "Refresh GTK Theme"; onClicked: {
                                        root.isOpen = false
                                        Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/hypr/scripts/gtk.sh"])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
