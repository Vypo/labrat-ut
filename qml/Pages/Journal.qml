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

    property RatJournal content
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

    header: Item {
        width: scroll.width
        height: if (scroll.replyOpen) {
            childrenRect.height
        } else {
            childrenRect.height - cmtReply.height
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                rightMargin: 10
            }

            id: contentText
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignJustify
            textFormat: Text.RichText
            text: content.header + "\n" + content.content + "\n" + content.footer
        }

        RowLayout {
            id: descLayout
            anchors {
                left: parent.left
                right: parent.right
                top: contentText.bottom
            }

            Item {
                Layout.preferredWidth: 8
            }

            Avatar {
                source: content.author.avatar
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
                    text: qsTr('by %1').arg(scroll.content.author.name)
                }
            }
        }

        CommentReply {
            id: cmtReply
            anchors {
                left: parent.left
                right: parent.right
                top: descLayout.bottom
            }
            replyOpen: scroll.replyOpen
            replyKey: scroll.content.replyKey
            onClosed: scroll.replyOpen = false
        }
    }
}
