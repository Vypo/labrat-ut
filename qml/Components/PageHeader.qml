import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Labrat 1.0

ToolBar {
    id: toolBar

    property alias avatar: img.source
    property alias title: titleLabel.text

    RowLayout {
        anchors.fill: parent
        ToolButton {
            text: qsTr("‹")
            onClicked: stack.pop()
            visible: stack.depth > 1
        }

        Label {
            id: titleLabel
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }

        Avatar {
            id: img
            small: true
        }
    }
}
