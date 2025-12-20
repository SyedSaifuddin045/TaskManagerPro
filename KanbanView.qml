import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: kanbanRoot

    /* ========= PUBLIC API ========= */

    property var kanbanTaskModel

    property color bgCard: "#252b48"
    property color bgMedium: "#1a1f3a"
    property color accentCyan: "#00d9ff"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#8b92b8"
    property color successGreen: "#00ff88"
    property color warningOrange: "#ff8c00"
    property color dangerRed: "#ff3366"

    signal deleteTaskRequested(int taskId, string taskName)

    Component.onCompleted: {
        console.log("[KANBAN ROOT] model =", kanbanTaskModel)
        console.log("[KANBAN ROOT] count =", kanbanTaskModel ? kanbanTaskModel.count : "NO MODEL")
    }

    /* ========= LAYOUT ========= */

    RowLayout {
        anchors.fill: parent
        spacing: 20

        KanbanColumn {
            id: pendingColumn
            title: "⏳ PENDING"
            colorAccent: accentCyan
            statusFilter: 0
            model: kanbanTaskModel
        }

        KanbanColumn {
            id: inProgressColumn
            title: "🔥 IN PROGRESS"
            colorAccent: warningOrange
            statusFilter: 1
            model: kanbanTaskModel
        }

        KanbanColumn {
            id: completedColumn
            title: "✅ COMPLETED"
            colorAccent: successGreen
            statusFilter: 2
            model: kanbanTaskModel
        }
    }

    /* ========= STYLED BUTTON COMPONENT ========= */

    component StyledButton: Rectangle {
        property string buttonText
        property color buttonColor: accentCyan
        signal clicked()

        implicitWidth: 80
        implicitHeight: 32
        radius: 8
        color: Qt.rgba(buttonColor.r, buttonColor.g, buttonColor.b, 0.15)
        border.width: 2
        border.color: Qt.rgba(buttonColor.r, buttonColor.g, buttonColor.b, 0.5)

        Label {
            anchors.centerIn: parent
            text: buttonText
            color: buttonColor
            font.bold: true
            font.pixelSize: 13
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
            hoverEnabled: true

            onEntered: parent.color = Qt.rgba(buttonColor.r, buttonColor.g, buttonColor.b, 0.25)
            onExited: parent.color = Qt.rgba(buttonColor.r, buttonColor.g, buttonColor.b, 0.15)
            onPressed: parent.scale = 0.95
            onReleased: parent.scale = 1.0
        }

        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    /* ========= KANBAN COLUMN ========= */

    component KanbanColumn: Rectangle {
        id: column
        Layout.fillWidth: true
        Layout.fillHeight: true

        color: kanbanRoot.bgMedium
        radius: 14
        border.width: 2
        border.color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.3)

        /* ---- API ---- */

        property string title
        property color colorAccent
        property int statusFilter
        property var model

        /* ---- STATE ---- */

        property int visibleCount: 0
        property var filteredModel: ListModel {}
        property bool isRebuildingSuppressed: false

        // Function to rebuild filtered model
        function rebuildFilteredModel() {
            if (isRebuildingSuppressed) {
                console.log("[COLUMN]", title, "rebuild suppressed")
                return
            }

            console.log("[COLUMN]", title, "rebuilding filtered model...")

            var oldCount = filteredModel.count
            filteredModel.clear()

            if (!model) {
                visibleCount = 0
                return
            }

            var statusRole = Qt.UserRole + 4  // TaskStatusRole
            var idRole = Qt.UserRole + 1      // TaskIdRole
            var nameRole = Qt.UserRole + 2    // TaskNameRole
            var descRole = Qt.UserRole + 3    // TaskDescriptionRole

            var count = 0
            for (var i = 0; i < model.rowCount(); i++) {
                var idx = model.index(i, 0)
                var status = model.data(idx, statusRole)

                if (status === statusFilter) {
                    filteredModel.append({
                        "taskId": model.data(idx, idRole),
                        "taskName": model.data(idx, nameRole),
                        "taskDescription": model.data(idx, descRole),
                        "taskStatus": status,
                        "sourceIndex": i
                    })
                    count++
                }
            }

            visibleCount = count
            console.log("[COLUMN]", title, "filtered model rebuilt, old count:", oldCount, "new count:", visibleCount)
        }

        // Smart update: only rebuild if our status is affected
        function smartUpdate(affectedStatuses) {
            if (!affectedStatuses || affectedStatuses.indexOf(statusFilter) !== -1) {
                rebuildFilteredModel()
            } else {
                console.log("[COLUMN]", title, "skipping rebuild - not affected")
            }
        }

        // Update filtered model when source model changes
        Connections {
            target: model

            function onRowsInserted() {
                column.rebuildFilteredModel()
            }

            function onRowsRemoved() {
                column.rebuildFilteredModel()
            }

            function onModelReset() {
                column.rebuildFilteredModel()
            }

            function onDataChanged(topLeft, bottomRight, roles) {
                // Only rebuild if status changed
                var statusRole = Qt.UserRole + 4
                if (!roles || roles.length === 0 || roles.indexOf(statusRole) !== -1) {
                    column.rebuildFilteredModel()
                }
            }
        }

        Component.onCompleted: {
            console.log("[COLUMN]", title)
            console.log("  model =", model)
            console.log("  count =", model ? model.count : "NO MODEL")
            rebuildFilteredModel()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            /* ===== HEADER ===== */

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 10
                color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.15)
                border.width: 2
                border.color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.4)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12

                    Label {
                        text: title
                        font.pixelSize: 15
                        font.bold: true
                        color: colorAccent
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.2)
                        border.width: 2
                        border.color: colorAccent

                        Label {
                            anchors.centerIn: parent
                            text: column.visibleCount
                            font.bold: true
                            color: colorAccent
                        }
                    }
                }
            }

            /* ===== LIST WITH DROP AREA ===== */

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Qt.rgba(0, 0, 0, 0.2)

                // Drop area for dragging tasks
                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    keys: ["kanbanTask"]

                    property int dropIndex: -1
                    property bool showInsertionLine: false
                    property real insertionY: 0

                    onPositionChanged: function(drag) {
                        if (!drag.source) return

                        // Don't show insertion indicator for same column
                        if (drag.source.draggedTaskStatus === column.statusFilter) {
                            showInsertionLine = false
                            return
                        }

                        // Calculate insertion position
                        var yPos = drag.y - list.y - list.anchors.margins
                        var currentY = 0
                        var targetIndex = 0

                        for (var i = 0; i < list.count; i++) {
                            var item = list.contentItem.children[i]
                            if (!item) continue

                            var itemHeight = item.height
                            if (yPos < currentY + itemHeight / 2) {
                                insertionY = list.y + list.anchors.margins + currentY
                                break
                            }
                            currentY += itemHeight + list.spacing
                            targetIndex = i + 1
                            insertionY = list.y + list.anchors.margins + currentY - list.spacing / 2
                        }

                        if (targetIndex >= list.count) {
                            insertionY = list.y + list.anchors.margins + currentY
                        }

                        dropIndex = targetIndex
                        showInsertionLine = true
                    }

                    onDropped: function(drop) {
                        console.log("=== DROP EVENT ===")
                        console.log("[DROP] Column:", title, "statusFilter:", column.statusFilter)
                        console.log("[DROP] Drop index:", dropArea.dropIndex)

                        // Hide indicators
                        dropIndicator.visible = false
                        dropArea.showInsertionLine = false
                        dropArea.dropIndex = -1

                        if (!drop.source || !kanbanRoot.kanbanTaskModel) {
                            console.log("[DROP] ERROR: No drop source or model!")
                            return
                        }

                        var taskId = drop.source.draggedTaskId
                        var fromStatus = drop.source.draggedTaskStatus
                        var toStatus = column.statusFilter

                        console.log("[DROP] Moving task", taskId, "from status", fromStatus, "to status", toStatus)

                        // Determine which columns are affected
                        var affectedStatuses = [fromStatus, toStatus]

                        // Change task status
                        if (toStatus === 0) {
                            if (typeof kanbanRoot.kanbanTaskModel.resetTask === "function") {
                                kanbanRoot.kanbanTaskModel.resetTask(taskId)
                            } else {
                                console.warn("[DROP] resetTask() method not available")
                                return
                            }
                        } else if (toStatus === 1) {
                            if (typeof kanbanRoot.kanbanTaskModel.startTask === "function") {
                                kanbanRoot.kanbanTaskModel.startTask(taskId)
                            } else {
                                return
                            }
                        } else if (toStatus === 2) {
                            if (typeof kanbanRoot.kanbanTaskModel.completeTask === "function") {
                                kanbanRoot.kanbanTaskModel.completeTask(taskId)
                            } else {
                                return
                            }
                        }

                        // Smart refresh: only update affected columns
                        Qt.callLater(function() {
                            pendingColumn.smartUpdate(affectedStatuses)
                            inProgressColumn.smartUpdate(affectedStatuses)
                            completedColumn.smartUpdate(affectedStatuses)
                        })

                        console.log("=== DROP COMPLETE ===")
                    }

                    onEntered: function(drag) {
                        if (!drag.source) return

                        // Only show general indicator if dropping to different column
                        if (drag.source.draggedTaskStatus !== column.statusFilter) {
                            dropIndicator.visible = true
                        }
                    }

                    onExited: {
                        dropIndicator.visible = false
                        dropArea.showInsertionLine = false
                        dropArea.dropIndex = -1
                    }

                    Rectangle {
                        id: dropIndicator
                        anchors.fill: parent
                        radius: 8
                        color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.15)
                        border.width: 2
                        border.color: Qt.rgba(colorAccent.r, colorAccent.g, colorAccent.b, 0.5)
                        visible: false

                        Label {
                            anchors.centerIn: parent
                            text: "Drop here"
                            font.pixelSize: 16
                            font.bold: true
                            color: colorAccent
                        }
                    }

                    // Insertion line indicator
                    Rectangle {
                        visible: dropArea.showInsertionLine
                        x: list.x + list.anchors.margins
                        y: dropArea.insertionY
                        width: list.width - list.anchors.margins * 2
                        height: 3
                        radius: 1.5
                        color: colorAccent
                        z: 1000

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 8
                            height: 8
                            radius: 4
                            color: colorAccent
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 8
                            height: 8
                            radius: 4
                            color: colorAccent
                        }
                    }

                    ListView {
                        id: list
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        spacing: 12
                        model: column.filteredModel

                        // Disable animations when rebuilding to prevent flicker
                        property bool animationsEnabled: true

                        add: animationsEnabled ? addTransition : null
                        remove: animationsEnabled ? removeTransition : null
                        displaced: animationsEnabled ? displacedTransition : null

                        Transition {
                            id: addTransition
                            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 250 }
                            NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                        }

                        Transition {
                            id: removeTransition
                            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                        }

                        Transition {
                            id: displacedTransition
                            NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                        }

                        delegate: Item {
                            id: delegateRoot
                            width: list.width
                            height: card.implicitHeight

                            Item {
                                id: dragProxy
                                visible: false
                                width: card.width
                                height: card.height
                                parent: kanbanRoot

                                Drag.active: dragArea.drag.active
                                Drag.source: dragProxy
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2
                                Drag.keys: ["kanbanTask"]

                                property int draggedTaskId: taskId
                                property int draggedTaskStatus: taskStatus

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 12
                                    color: kanbanRoot.bgCard
                                    border.width: 2
                                    border.color: colorAccent
                                    opacity: 0.8

                                    Label {
                                        anchors.centerIn: parent
                                        text: taskName
                                        font.bold: true
                                        color: kanbanRoot.textPrimary
                                    }
                                }
                            }

                            Rectangle {
                                id: card
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                implicitHeight: content.implicitHeight + 28
                                radius: 12
                                color: kanbanRoot.bgCard
                                border.width: 2
                                border.color: dragArea.pressed ? colorAccent : Qt.rgba(1, 1, 1, 0.1)

                                Behavior on implicitHeight {
                                    NumberAnimation { duration: 200 }
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }

                                states: [
                                    State {
                                        when: dragArea.drag.active
                                        PropertyChanges {
                                            target: card
                                            opacity: 0.3
                                        }
                                        PropertyChanges {
                                            target: dragProxy
                                            visible: true
                                        }
                                    }
                                ]

                                transitions: Transition {
                                    NumberAnimation {
                                        properties: "opacity"
                                        duration: 150
                                    }
                                }

                                MouseArea {
                                    id: dragArea
                                    anchors.fill: parent
                                    drag.target: dragProxy
                                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                                    onPressed: {
                                        dragProxy.x = kanbanRoot.mapFromItem(card, 0, 0).x
                                        dragProxy.y = kanbanRoot.mapFromItem(card, 0, 0).y
                                    }

                                    onReleased: {
                                        dragProxy.Drag.drop()
                                        dragProxy.visible = false
                                    }
                                }

                                ColumnLayout {
                                    id: content
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Label {
                                        text: taskName
                                        font.bold: true
                                        font.pixelSize: 15
                                        color: kanbanRoot.textPrimary
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                    }

                                    Label {
                                        text: taskDescription
                                        font.pixelSize: 13
                                        color: kanbanRoot.textSecondary
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                    }

                                    RowLayout {
                                        spacing: 8
                                        Layout.fillWidth: true

                                        StyledButton {
                                            buttonText: "▶ Start"
                                            buttonColor: kanbanRoot.warningOrange
                                            visible: taskStatus === 0
                                            onClicked: kanbanRoot.kanbanTaskModel.startTask(taskId)
                                        }

                                        StyledButton {
                                            buttonText: "✓ Done"
                                            buttonColor: kanbanRoot.successGreen
                                            visible: taskStatus !== 2
                                            onClicked: kanbanRoot.kanbanTaskModel.completeTask(taskId)
                                        }

                                        Item { Layout.fillWidth: true }

                                        StyledButton {
                                            buttonText: "✖ Delete"
                                            buttonColor: kanbanRoot.dangerRed
                                            implicitWidth: 90
                                            onClicked: kanbanRoot.deleteTaskRequested(taskId, taskName)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Label {
                visible: column.visibleCount === 0
                text: "No tasks · Drag tasks here"
                color: kanbanRoot.textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }
}
