import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    title: "Welcome App"
    visible: true

    Text {
        anchors.centerIn: parent
        text: "Hello from QML"
        font.pointSize: 20
    }
}
