import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ToolButton {
    id: btn
    property int count: 0
    property alias bubbleColor: bubbleRect.color
    property alias buttonText: btnLabel.text

    contentItem: RowLayout {
        Label {
            id: btnLabel
            Layout.maximumWidth: parent.width * 0.5
            Layout.fillHeight: true
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            font.bold: btn.count > 0
        }

        Rectangle {
            id: bubbleRect
            Layout.maximumWidth: parent.width * 0.5
            Layout.minimumWidth: childrenRect.width + 20
            Layout.preferredHeight: parent.height
            Layout.alignment: Qt.AlignRight

            visible: btn.count != 0
            radius: height * 0.25

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                text: btn.count
                color: 'white'
            }
        }
    }
}
