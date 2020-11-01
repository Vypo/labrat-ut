import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Labrat 1.0

import "../Components"

ListView {
    id: scroll
    clip: true
    height: parent.height
    width: parent.width

    property RatView content
    property bool replyOpen: false

    model: content.comments
    delegate: Comment {
        text: model.text
        avatarSource: model.commenter_avatar
        commenterName: model.commenter_name
        depth: model.depth
        replyKey: model.replyKey
    }

    footerPositioning: ListView.OverlayFooter
    footer:  RowLayout {
        anchors {
            right: parent.right
            left: parent.left
        }

        // TODO: Animate the button appearing.
        visible: scroll.atYBeginning && !scroll.replyOpen
        id: replyFab

        Item {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            Layout.margins: 30
            Layout.alignment: Qt.AlignRight

            RoundButton {
                id: replyBtn
                text: qsTr('↵')
                anchors.fill: parent
                highlighted: true
                font.pixelSize: height / 2
                onClicked: scroll.replyOpen = true
            }

            DropShadow {
                source: replyBtn
                anchors.fill: replyBtn
                radius: 6.0
                color: "#80000000"
            }
        }
    }

    header: ColumnLayout {
        id: layout
        width: scroll.width

        AnimatedImage {
            id: img
            source: scroll.content.fullview
            onPaintedHeightChanged: {
                // TODO: Without this the image loads above the fold.
                if (img.status === Image.Ready) {
                    scroll.contentY = -layout.height
                }
            }
            Layout.alignment: Qt.AlignTop
            Layout.preferredHeight: (sourceSize.height / sourceSize.width) * width
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            autoTransform: true
            fillMode: Image.PreserveAspectFit
            clip: true
            verticalAlignment: Qt.AlignTop
        }

        ToolBar {
            id: tools
            Layout.fillWidth: true
            RowLayout {
                width: parent.width

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: false

                    ToolButton {
                        text: qsTr('★')
                        onClicked: controller0.unfav(content.favKey)
                        visible: content.showUnfav
                    }
                    ToolButton {
                        text: qsTr('☆')
                        visible: content.showFav
                        onClicked: controller0.fav(content.favKey)
                    }
                    DownloadButton {
                        downloadSource: content.download
                    }
                }
            }
        }

        RowLayout {
            Item {
                Layout.preferredWidth: 8
            }

            Avatar {
                source: content.artist.avatar
            }

            Item {
                Layout.preferredWidth: 8
            }

            ColumnLayout {
                Layout.fillWidth: true

                Label {
                    text: scroll.content.title
                    font.bold: true
                }

                Label {
                    text: qsTr('by %1').arg(scroll.content.artist.name)
                }
            }
        }

        Text {
            text: scroll.content.description
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignJustify
            Layout.topMargin: tools.height / 2
            Layout.bottomMargin: tools.height / 2
            Layout.preferredWidth: parent.width * 0.8
            Layout.maximumWidth: parent.width * 0.8
            Layout.alignment: Qt.AlignHCenter
        }

        CommentReply {
            replyOpen: scroll.replyOpen
            replyKey: scroll.content.replyKey
        }
    }
}
