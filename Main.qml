import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 1080
    title: "Task Manager Pro"

    // Futuristic color scheme
    readonly property color bgDark: "#0a0e27"
    readonly property color bgMedium: "#1a1f3a"
    readonly property color bgCard: "#252b48"
    readonly property color accentCyan: "#00d9ff"
    readonly property color accentPurple: "#b537f2"
    readonly property color accentPink: "#ff2e97"
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#8b92b8"
    readonly property color successGreen: "#00ff88"
    readonly property color warningOrange: "#ff8c00"
    readonly property color dangerRed: "#ff3366"

    property bool isKanbanView: false

    Component.onDestruction: {
        console.log("Saving tasks...")
        taskModel.saveToFile()
    }

    // Animated gradient background
    Rectangle {
        anchors.fill: parent
        color: bgDark

        Canvas {
            id: bgCanvas
            anchors.fill: parent

            property real time: 0

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                // Gradient circles
                var gradient1 = ctx.createRadialGradient(width * 0.2, height * 0.3, 0, width * 0.2, height * 0.3, width * 0.5)
                gradient1.addColorStop(0, Qt.rgba(0.71, 0.22, 0.95, 0.1))
                gradient1.addColorStop(1, Qt.rgba(0.71, 0.22, 0.95, 0))

                var gradient2 = ctx.createRadialGradient(width * 0.8, height * 0.7, 0, width * 0.8, height * 0.7, width * 0.5)
                gradient2.addColorStop(0, Qt.rgba(0, 0.85, 1, 0.1))
                gradient2.addColorStop(1, Qt.rgba(0, 0.85, 1, 0))

                ctx.fillStyle = gradient1
                ctx.fillRect(0, 0, width, height)

                ctx.fillStyle = gradient2
                ctx.fillRect(0, 0, width, height)
            }

            Timer {
                interval: 50
                running: true
                repeat: true
                onTriggered: {
                    bgCanvas.time += 0.01
                    bgCanvas.requestPaint()
                }
            }
        }
    }

    // Custom header
    header: Rectangle {
        height: 80
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: bgMedium
            opacity: 0.8

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: accentCyan
                opacity: 0.3
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Title with glow effect
            Item {
                Layout.preferredWidth: 300
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Label {
                        text: "TASK MANAGER"
                        font.pixelSize: 24
                        font.bold: true
                        font.letterSpacing: 2
                        color: textPrimary

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: accentCyan
                            shadowBlur: 0.3
                        }
                    }

                    Label {
                        text: "Stay Organized, Stay Ahead"
                        font.pixelSize: 11
                        color: textSecondary
                        font.letterSpacing: 1
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Row {
                spacing: 10
                Layout.alignment: Qt.AlignVCenter

                Label {
                    text: "VIEW:"
                    font.bold: true
                    font.pixelSize: 12
                    font.letterSpacing: 1.5
                    color: textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    text: isKanbanView ? "\uf0ce" : "\uf03a"
                    font.pixelSize: 12
                    font.bold: true
                    width: 120
                    height: 36

                    background: Rectangle {
                        radius: 8
                        color: bgCard
                        border.width: 1
                        border.color: accentPurple
                        opacity: parent.hovered ? 1 : 0.7

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: accentPurple
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        isKanbanView = !isKanbanView
                    }
                }
            }

            // Stats panel
            Row {
                spacing: 30

                StatCard {
                    label: "TOTAL"
                    value: taskModel.count
                    iconText: "📊"
                    glowColor: accentCyan
                }

                StatCard {
                    label: "ACTIVE"
                    value: getActiveCount()
                    iconText: "⚡"
                    glowColor: warningOrange
                }

                StatCard {
                    label: "DONE"
                    value: getCompletedCount()
                    iconText: "✓"
                    glowColor: successGreen
                }
            }

            // Add button
            Button {
                text: "+"
                font.pixelSize: 32
                font.bold: true
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60

                background: Rectangle {
                    radius: 30
                    color: bgCard
                    border.width: 2
                    border.color: accentCyan

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: accentCyan
                        opacity: parent.parent.hovered ? 0.2 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: accentCyan
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: addTaskDialog.open()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Filter bar (keep it exactly as you have it)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: bgMedium
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Label {
                    text: "FILTER:"
                    font.bold: true
                    font.pixelSize: 12
                    font.letterSpacing: 1.5
                    color: textSecondary
                }

                ButtonGroup { id: filterGroup }

                Repeater {
                    model: [
                        { text: "ALL", value: -1, icon: "∞" },
                        { text: "PENDING", value: 0, icon: "○" },
                        { text: "ACTIVE", value: 1, icon: "◐" },
                        { text: "DONE", value: 2, icon: "●" }
                    ]

                    FilterButton {
                        text: modelData.text
                        iconText: modelData.icon
                        checked: index === 0
                        ButtonGroup.group: filterGroup
                        onClicked: taskListView.currentFilter = modelData.value
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: sortAscending ? "🔽 PRIORITY" : "🔼 PRIORITY"
                    font.pixelSize: 12
                    font.bold: true
                    property bool sortAscending: false
                    background: Rectangle { radius: 8; color: bgCard; border.width: 1; border.color: accentCyan; opacity: parent.hovered ? 1 : 0.7; Behavior on opacity { NumberAnimation { duration: 200 } } }
                    contentItem: Text { text: parent.text; font: parent.font; color: accentCyan; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        sortAscending = !sortAscending
                        taskModel.sortByPriority(sortAscending)
                        sortNotification.notificationText = sortAscending ? "Sorted: Low → High" : "Sorted: High → Low"
                        sortNotification.show()
                    }
                }

                Button {
                    text: "💾 SAVE"
                    font.pixelSize: 12
                    font.bold: true
                    background: Rectangle { radius: 8; color: bgCard; border.width: 1; border.color: accentPurple; opacity: parent.hovered ? 1 : 0.7; Behavior on opacity { NumberAnimation { duration: 200 } } }
                    contentItem: Text { text: parent.text; font: parent.font; color: accentPurple; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: { taskModel.saveToFile(); saveNotification.show() }
                }
            }
        }

        // NEW: View area that switches between List and Kanban
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 12
            clip: true

            // List View (your original view)
            ListView {
                id: taskListView
                anchors.fill: parent
                visible: !isKanbanView
                spacing: 12
                clip: true
                property int currentFilter: -1
                model: taskModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 6; radius: 3; color: accentCyan
                        opacity: parent.pressed ? 0.8 : parent.hovered ? 0.5 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }

                delegate: Item {
                    id: delegateRoot
                    width: taskListView.width
                    height: taskCard.visible ? taskCard.implicitHeight : 0

                    property bool matchesFilter: taskListView.currentFilter === -1 || taskStatus === taskListView.currentFilter

                    Rectangle {
                        id: taskCard
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        implicitHeight: visible ? cardContent.implicitHeight + 40 : 0
                        visible: delegateRoot.matchesFilter
                        opacity: visible ? 1 : 0

                        color: bgCard
                        radius: 15
                        border.width: 2
                        border.color: Qt.rgba(0, 0.85, 1, 0.2)

                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        Behavior on implicitHeight { NumberAnimation { duration: 300 } }

                        // Priority accent bar
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 2
                            anchors.bottomMargin: 2
                            width: 6
                            radius: 3
                            color: taskPriority === 2 ? dangerRed :
                                   taskPriority === 1 ? warningOrange : successGreen

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: parent.color
                                shadowBlur: 0.8
                            }
                        }

                        // Glow effect on hover
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 2
                            border.color: accentCyan
                            opacity: cardMouseArea.containsMouse ? 0.5 : 0

                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            id: cardMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            onPressed: mouse.accepted = false
                        }

                        RowLayout {
                            id: cardContent
                            anchors.fill: parent
                            anchors.margins: 20
                            anchors.leftMargin: 30
                            spacing: 20

                            // Status indicator (FIXED)
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                width: 50
                                height: 50
                                radius: 25
                                color: Qt.rgba(0, 0, 0, 0.4)
                                border.width: 3
                                border.color: {
                                    if (isCompleted) return successGreen
                                    if (taskStatus === 1) return warningOrange
                                    return accentCyan
                                }

                                // Safe shadow: use explicit color instead of binding to parent.border.color
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: isCompleted ? successGreen :
                                                  taskStatus === 1 ? warningOrange : accentCyan
                                    shadowBlur: 0.6
                                }

                                Label {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -3
                                    text: isCompleted ? "✓" : taskStatus === 1 ? "◐" : "○"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: isCompleted ? successGreen :
                                           taskStatus === 1 ? warningOrange : accentCyan
                                }
                            }

                            // Content area
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 12

                                // Task name
                                Label {
                                    text: taskName
                                    font.pixelSize: 20
                                    font.bold: true
                                    font.letterSpacing: 0.5
                                    color: isCompleted ? textSecondary : textPrimary
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true

                                    layer.enabled: !isCompleted
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true
                                        shadowColor: Qt.rgba(1, 1, 1, 0.3)
                                        shadowBlur: 0.2
                                    }
                                }

                                // Task description
                                Label {
                                    text: taskDescription
                                    font.pixelSize: 15
                                    color: textSecondary
                                    opacity: 0.9
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: parent.width
                                    visible: text !== ""
                                }

                                // Meta info tags
                                Flow {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 5
                                    spacing: 12

                                    MetaTag {
                                        text: "🎯 " + taskModel.priorityToString(taskPriority)
                                        tagColor: taskPriority === 2 ? dangerRed :
                                                 taskPriority === 1 ? warningOrange : successGreen
                                    }

                                    MetaTag {
                                        text: "⚡ " + taskModel.statusToString(taskStatus)
                                        tagColor: isCompleted ? successGreen :
                                                 taskStatus === 1 ? warningOrange : accentCyan
                                    }

                                    MetaTag {
                                        text: "📅 " + createdTime
                                        tagColor: Qt.rgba(0.55, 0.57, 0.72, 1)
                                    }
                                }
                            }

                            // Action buttons
                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 12

                                ActionButton {
                                    text: "▶ START"
                                    visible: taskStatus === 0
                                    buttonColor: warningOrange
                                    onClicked: taskModel.startTask(taskId)
                                    Layout.preferredWidth: 120
                                }

                                ActionButton {
                                    text: "✓ COMPLETE"
                                    visible: taskStatus !== 2
                                    buttonColor: successGreen
                                    onClicked: taskModel.completeTask(taskId)
                                    Layout.preferredWidth: 120
                                }

                                ActionButton {
                                    text: "✕ DELETE"
                                    buttonColor: dangerRed
                                    onClicked: {
                                        deleteConfirmDialog.taskIdToDelete = taskId
                                        deleteConfirmDialog.taskNameToDelete = taskName
                                        deleteConfirmDialog.open()
                                    }
                                    Layout.preferredWidth: 120
                                }
                            }
                        }

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.6)
                            shadowBlur: 0.4
                            shadowVerticalOffset: 4
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: taskListView.count === 0
                    text: "No tasks yet.\nClick + to add your first task!"
                    font.pixelSize: 18
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Kanban View (from the separate file)
            KanbanView {
                anchors.fill: parent
                visible: isKanbanView
                kanbanTaskModel: taskModel

                // Connect the delete signal to your dialog
                onDeleteTaskRequested: (taskId, taskName) => {
                    deleteConfirmDialog.taskIdToDelete = taskId
                    deleteConfirmDialog.taskNameToDelete = taskName
                    deleteConfirmDialog.open()
                }
            }
        }
    }

    // Add Task Dialog
    Dialog {
        id: addTaskDialog
        anchors.centerIn: parent
        width: 500
        modal: true

        background: Rectangle {
            color: bgMedium
            radius: 20
            border.width: 2
            border.color: accentCyan

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0.85, 1, 0.5)
                shadowBlur: 0.5
            }
        }

        header: Item {
            height: 60

            Label {
                anchors.centerIn: parent
                text: "CREATE NEW TASK"
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 2
                color: textPrimary
            }
        }

        contentItem: ColumnLayout {
            spacing: 20

            Label {
                text: "TASK NAME"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
                color: textSecondary
            }

            TextField {
                id: taskNameField
                Layout.fillWidth: true
                placeholderText: "Enter task name..."
                font.pixelSize: 14
                color: textPrimary

                background: Rectangle {
                    color: bgCard
                    radius: 8
                    border.width: 2
                    border.color: parent.activeFocus ? accentCyan : Qt.rgba(1, 1, 1, 0.1)

                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }
            }

            Label {
                text: "DESCRIPTION"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
                color: textSecondary
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 120

                TextArea {
                    id: taskDescField
                    placeholderText: "Enter task description..."
                    font.pixelSize: 14
                    color: textPrimary
                    wrapMode: TextArea.Wrap

                    background: Rectangle {
                        color: bgCard
                        radius: 8
                        border.width: 2
                        border.color: parent.activeFocus ? accentCyan : Qt.rgba(1, 1, 1, 0.1)

                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            Label {
                text: "PRIORITY"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
                color: textSecondary
            }

            ComboBox {
                id: priorityCombo
                Layout.fillWidth: true
                model: ["🟢 Low", "🟡 Medium", "🔴 High"]
                currentIndex: 1
                font.pixelSize: 14

                background: Rectangle {
                    color: bgCard
                    radius: 8
                    border.width: 2
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }

                contentItem: Text {
                    text: priorityCombo.displayText
                    font: priorityCombo.font
                    color: textPrimary
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 15
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 15

                Button {
                    text: "CANCEL"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: bgCard
                        radius: 10
                        border.width: 2
                        border.color: textSecondary
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: addTaskDialog.close()
                }

                Button {
                    text: "CREATE TASK"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: accentCyan
                        radius: 10
                        opacity: parent.hovered ? 1 : 0.9

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: accentCyan
                            shadowBlur: 0.5
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: bgDark
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (taskNameField.text.trim() !== "") {
                            console.log("Adding task:", taskNameField.text)
                            taskModel.addTask(
                                taskNameField.text,
                                taskDescField.text,
                                priorityCombo.currentIndex
                            )
                            taskNameField.clear()
                            taskDescField.clear()
                            priorityCombo.currentIndex = 1
                            addTaskDialog.close()
                            addNotification.show()
                        }
                    }
                }
            }
        }
    }

    // Save notification
    Rectangle {
        id: saveNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 200
        height: 50
        radius: 25
        color: bgCard
        border.width: 2
        border.color: successGreen
        opacity: 0

        function show() {
            opacity = 1
            hideTimer.restart()
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }

        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: saveNotification.opacity = 0
        }

        Label {
            anchors.centerIn: parent
            text: "✓ Saved!"
            font.pixelSize: 16
            font.bold: true
            color: successGreen
        }
    }

    // Delete confirmation dialog
    Dialog {
        id: deleteConfirmDialog
        anchors.centerIn: parent
        width: 400
        modal: true

        property int taskIdToDelete: 0
        property string taskNameToDelete: ""

        background: Rectangle {
            color: bgMedium
            radius: 20
            border.width: 2
            border.color: dangerRed

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(1, 0.2, 0.4, 0.5)
                shadowBlur: 0.5
            }
        }

        header: Item {
            height: 60

            Label {
                anchors.centerIn: parent
                text: "⚠ DELETE TASK"
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 2
                color: dangerRed
            }
        }

        contentItem: ColumnLayout {
            spacing: 20

            Label {
                text: "Are you sure you want to delete this task?"
                font.pixelSize: 15
                color: textPrimary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: bgCard
                radius: 10
                border.width: 1
                border.color: dangerRed

                Label {
                    anchors.centerIn: parent
                    anchors.margins: 10
                    text: '"' + deleteConfirmDialog.taskNameToDelete + '"'
                    font.pixelSize: 14
                    font.italic: true
                    color: textSecondary
                    wrapMode: Text.Wrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Label {
                text: "This action cannot be undone."
                font.pixelSize: 12
                color: textSecondary
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 15

                Button {
                    text: "CANCEL"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: bgCard
                        radius: 10
                        border.width: 2
                        border.color: textSecondary
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: deleteConfirmDialog.close()
                }

                Button {
                    text: "DELETE"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        color: dangerRed
                        radius: 10
                        opacity: parent.hovered ? 1 : 0.9

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: dangerRed
                            shadowBlur: 0.5
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: bgDark
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Deleting task ID:", deleteConfirmDialog.taskIdToDelete)
                        taskModel.removeTask(deleteConfirmDialog.taskIdToDelete)
                        deleteConfirmDialog.close()
                        deleteNotification.show()
                    }
                }
            }
        }
    }

    // Delete notification
    Rectangle {
        id: deleteNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 200
        height: 50
        radius: 25
        color: bgCard
        border.width: 2
        border.color: dangerRed
        opacity: 0

        function show() {
            opacity = 1
            deleteHideTimer.restart()
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }

        Timer {
            id: deleteHideTimer
            interval: 2000
            onTriggered: deleteNotification.opacity = 0
        }

        Label {
            anchors.centerIn: parent
            text: "✓ Deleted!"
            font.pixelSize: 16
            font.bold: true
            color: dangerRed
        }
    }

    // Add notification
    Rectangle {
        id: addNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 220
        height: 50
        radius: 25
        color: bgCard
        border.width: 2
        border.color: accentCyan
        opacity: 0

        function show() {
            opacity = 1
            addHideTimer.restart()
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }

        Timer {
            id: addHideTimer
            interval: 2000
            onTriggered: addNotification.opacity = 0
        }

        Label {
            anchors.centerIn: parent
            text: "✓ Task Added!"
            font.pixelSize: 16
            font.bold: true
            color: accentCyan
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: accentCyan
            shadowBlur: 0.6
        }
    }

    // Sort notification
    Rectangle {
        id: sortNotification
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 250
        height: 50
        radius: 25
        color: bgCard
        border.width: 2
        border.color: accentCyan
        opacity: 0

        property string notificationText: "Sorted!"

        function show() {
            opacity = 1
            sortHideTimer.restart()
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }

        Timer {
            id: sortHideTimer
            interval: 2000
            onTriggered: sortNotification.opacity = 0
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Label {
                text: "↕"
                font.pixelSize: 20
                font.bold: true
                color: accentCyan
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: sortNotification.notificationText
                font.pixelSize: 16
                font.bold: true
                color: accentCyan
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: accentCyan
            shadowBlur: 0.6
        }
    }

    // Helper functions
    function getActiveCount() {
        var count = 0
        for (var i = 0; i < taskModel.count; i++) {
            var status = taskModel.data(taskModel.index(i, 0), 259) // TaskStatusRole
            if (status === 0 || status === 1) count++
        }
        return count
    }

    function getCompletedCount() {
        var count = 0
        for (var i = 0; i < taskModel.count; i++) {
            var completed = taskModel.data(taskModel.index(i, 0), 261) // TaskIsCompletedRole
            if (completed) count++
        }
        return count
    }

    // Custom components
    component StatCard: Rectangle {
        property string label: ""
        property int value: 0
        property string iconText: ""
        property color glowColor: accentCyan  // Default to prevent undefined

        width: 100
        height: 60
        color: bgCard
        radius: 12
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            Label {
                text: iconText + " " + value
                font.pixelSize: 24
                font.bold: true
                color: glowColor  // Direct reference is now safe
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: label
                font.pixelSize: 10
                font.letterSpacing: 1
                color: textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Move the layer.effect here and use a conditional to avoid undefined
        layer.enabled: glowColor !== undefined  // Fallback if still undefined (rare)
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: glowColor
            shadowBlur: 0.5
        }
    }

    component FilterButton: Button {
        property string iconText

        checkable: true
        font.pixelSize: 11
        font.bold: true
        font.letterSpacing: 1

        contentItem: Row {
            spacing: 5

            Label {
                text: iconText
                font.pixelSize: 14
                color: parent.parent.checked ? accentCyan : textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: parent.parent.text
                font: parent.parent.font
                color: parent.parent.checked ? accentCyan : textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        background: Rectangle {
            radius: 8
            color: parent.checked ? Qt.rgba(0, 0.85, 1, 0.15) : "transparent"
            border.width: 1
            border.color: parent.checked ? accentCyan : Qt.rgba(1, 1, 1, 0.1)

            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }
        }
    }

    component MetaTag: Rectangle {
        property string text
        property color tagColor

        implicitWidth: tagText.implicitWidth + 24
        implicitHeight: 32
        radius: 16
        color: Qt.rgba(tagColor.r, tagColor.g, tagColor.b, 0.2)
        border.width: 2
        border.color: Qt.rgba(tagColor.r, tagColor.g, tagColor.b, 0.5)

        Label {
            id: tagText
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 0.5
            color: tagColor
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(tagColor.r, tagColor.g, tagColor.b, 0.3)
            shadowBlur: 0.3
        }
    }

    component ActionButton: Button {
        property color buttonColor

        text: ""
        font.pixelSize: 12
        font.bold: true
        font.letterSpacing: 1.2

        implicitWidth: 120
        implicitHeight: 42

        background: Rectangle {
            radius: 10
            color: buttonColor
            opacity: parent.hovered ? 1 : 0.85

            Behavior on opacity { NumberAnimation { duration: 200 } }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: buttonColor
                shadowBlur: parent.parent.hovered ? 0.8 : 0.4
                shadowVerticalOffset: 2

                Behavior on shadowBlur { NumberAnimation { duration: 200 } }
            }
        }

        contentItem: Text {
            text: parent.text
            font: parent.font
            color: bgDark
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
