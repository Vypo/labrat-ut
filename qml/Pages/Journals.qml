import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Labrat 1.0

import "../Components"

ListView {
    property RatJournals content

    id: listView
    clip: true
    height: parent.height
    width: parent.width
    model: content.model
    spacing: 0

    Component.onCompleted: controller0.fetchOthers()

    delegate: SwipeDelegate {
        id: swipeDelegate

        swipe.onCompleted: alert("TODO")

        onClicked: controller0.fetchJournal(model.key)

        anchors {
            left: parent.left
            right: parent.right
        }

        padding: 0
        spacing: 0
        topPadding: 0
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0

        background: Rectangle {
            id: swipeBg
            width: parent.width
            height: parent.height
            color: 'transparent'
        }

        swipe.left: Label {
            text: qsTr('✖')
            font.pixelSize: 12
            color: 'white'
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignRight
            padding: 12
            height: parent.height
            width: listView.width
            anchors.right: swipeBg.left

            background: Rectangle {
                color: 'tomato'
            }
        }

        swipe.right: Label {
            text: qsTr('✖')
            font.pixelSize: 12
            color: 'white'
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignLeft
            padding: 12
            height: parent.height
            width: listView.width
            anchors.left: swipeBg.right

            background: Rectangle {
                color: 'tomato'
            }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction {
                target: swipeDelegate
                property: "ListView.delayRemove"
                value: true
            }
            NumberAnimation {
                target: swipeDelegate
                property: "height"
                to: 0
                easing.type: Easing.InOutQuad
            }
            PropertyAction {
                target: swipeDelegate
                property: "ListView.delayRemove"
                value: false
            }
        }

        contentItem: ColumnLayout {
            width: parent.width

            Item {
                height: 10
            }

            RowLayout {
                Layout.maximumWidth: listView.width - 20
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                spacing: 10

                Avatar {
                    small: false
                    source: model.author_avatar
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Label {
                        id: subTitle
                        text: model.title
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                        font.bold: true
                    }

                    Label {
                        text: qsTr('by %1').arg(model.author_name)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        fontSizeMode: Text.Fit
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: true
                    }
                }
            }

            Item {
                height: 9
            }
            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: '#cccccc'
            }

        }
    }
}
