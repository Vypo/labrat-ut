import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Labrat 1.0


ColumnLayout {
    signal closed
    property bool replyOpen: false
    property var replyKey

    id: replyRoot
    visible: replyOpen
    Layout.fillWidth: true

    Rectangle {
        color: '#cccccc'
        Layout.preferredHeight: 1
        Layout.fillWidth: true
    }

    TextArea {
        id: replyText
        Layout.fillWidth: true
        Layout.margins: 10
        placeholderText: qsTr('reply here...')
    }

    RowLayout {
        Layout.fillWidth: true

        Item {
            Layout.fillWidth: true
        }

        Button {
            text: qsTr('Cancel')
            Layout.alignment: Qt.AlignRight
            onClicked: {
                replyText.text = "";
                closed();
            }
        }

        Button {
            text: qsTr('Send')
            Layout.alignment: Qt.AlignRight
            highlighted: true
            onClicked: {
                controller0.reply(replyRoot.replyKey, replyText.text);
                replyText.text = "";
                closed();
            }
        }
    }
}
