import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Labrat 1.0

Item {
    id: welcome

    property bool isWelcome: true

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Label {
            text: qsTr("Welcome!")
            Layout.fillWidth: true
            font.pointSize: 24
            horizontalAlignment: Qt.AlignHCenter
        }

        Button {
            text: qsTr("Login to FurAffinity")
            Layout.alignment: Qt.AlignHCenter
            highlighted: true
            visible: !controller0.credentials || controller0.credentials.byteLength == 0
            onClicked: stack.push(loginView)
        }
    }
}
