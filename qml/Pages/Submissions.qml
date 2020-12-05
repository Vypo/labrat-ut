import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Labrat 1.0

import "../Components"
ListView {
    property RatSubmissions content

    id: listView
    clip: true
    height: parent.height
    width: parent.width
    model: content.model
    spacing: 0
    onAtYEndChanged: if (model && listView.atYEnd) {
        controller0.fetchSubmissions(content.next)
    }

    delegate: SwipeDelegate {
        id: swipeDelegate

        swipe.onCompleted: {
            controller0.clearSubmission(model.key)
            content.remove(model.key)
        }

        onClicked: controller0.fetchView(model.key)

        anchors {
            left: parent.left
            right: parent.right
        }

        height: width
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
        }

        swipe.left: Label {
            text: qsTr('✖')
            font.pixelSize: height / 10
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
            font.pixelSize: height / 10
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

        contentItem: Rectangle {
            width: parent.width
            height: parent.height
            color: if (checkBox.checked) {
                'lavender'
            } else {
                'white'
            }

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    height: 2
                    Layout.fillWidth: true
                    color: "#eeeeee"
                }

                Item {
                    Layout.preferredHeight: 5
                }

                RowLayout {
                    id: subTopRow
                    Layout.maximumWidth: parent.width - 20
                    Layout.alignment: Qt.AlignHCenter

                    Avatar {
                        small: true
                        source: model.artist_avatar
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            text: model.artist_name
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Qt.AlignLeft
                            font.bold: true
                        }
                    }

                    Button {
                        text: 'TODO'
                        onClicked: content.clearMarked()
                    }

                    CheckBox {
                        id: checkBox
                        onCheckedChanged: content.mark(model.key, checked)
                        Component.onCompleted: checked = content.isMarked(model.key)
                    }
                }

                Item {
                    Layout.preferredHeight: 5
                }

                AnimatedImage {
                    Layout.preferredWidth: parent.width
                    Layout.fillHeight: true
                    source: model.preview
                    autoTransform: true
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }

                Item {
                    Layout.preferredHeight: 5
                }

                RowLayout {
                    Layout.preferredHeight: subTopRow.height
                    Layout.maximumWidth: parent.width - 20
                    Layout.alignment: Qt.AlignHCenter

                    Label {
                        Layout.maximumWidth: parent.width
                        id: subTitle
                        text: model.title
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        horizontalAlignment: Qt.AlignLeft
                    }
                }

                Item {
                    Layout.preferredHeight: 5
                }

                Rectangle {
                    height: 2
                    Layout.fillWidth: true
                    color: "#eeeeee"
                }
            }
        }
    }
}
