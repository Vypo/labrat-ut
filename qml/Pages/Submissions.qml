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

            AnimatedImage {
                anchors {
                    fill: parent
                }

                source: model.preview
                height: (sourceSize.height / sourceSize.width) * width
                autoTransform: true
                fillMode: Image.PreserveAspectCrop
                clip: true
                verticalAlignment: Qt.AlignVCenter
            }

            RowLayout {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 10
                }

                height: 42

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: subRow.width + 20

                    radius: 21
                    color: 'white'

                    border {
                        color: '#cccccc'
                        width: 1
                    }

                    RowLayout {
                        id: subRow
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        Avatar {
                            small: true
                            source: model.artist_avatar
                        }
                        ColumnLayout {
                            Layout.maximumWidth: listView.width / 2
                            spacing: 0

                            Label {
                                Layout.maximumWidth: listView.width / 2
                                id: subTitle
                                text: model.title
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Label {
                                Layout.maximumWidth: listView.width / 2
                                text: qsTr('by %1').arg(model.artist_name)
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                fontSizeMode: Text.Fit
                            }
                        }
                    }
                }
            }
        }
    }
}
