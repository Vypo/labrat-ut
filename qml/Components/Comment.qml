import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Labrat 1.0

MouseArea {
    property alias commenterName: commenter.text
    property alias text: body.text
    property alias avatarSource: avatar.source
    property alias replyKey: commentReply.replyKey
    property alias replyOpen: commentReply.replyOpen

    property int depth: 0

    id: comment

    Layout.preferredWidth: parent.width - 2
    anchors.right: parent.right

    height: childrenRect.height
    width: parent.width

    onPressAndHold: comment.replyOpen = true

    RowLayout {
        spacing: 0
        width: parent.width

        Rectangle {
            id: depthRect
            Layout.fillHeight: true
            Layout.leftMargin: if (comment.depth > 0) { 4 * (comment.depth - 1) } else { 0 }
            Layout.preferredWidth: if (comment.depth > 0) { 4 } else { 0 }
            color: {
                const colors = [
                    '#563c96', '#bb3a28', '#752b41', '#d85922', '#2042a0',
                    '#e0ad56', '#e8b0b3', '#71a63e', '#c97626'
                ];

                return colors[depth % colors.length];
            }
        }

        ColumnLayout {
            Layout.bottomMargin: 5
            Layout.preferredWidth: {
                comment.width -
                    (depthRect.Layout.leftMargin + depthRect.width);
            }

            Rectangle {
                color: '#cccccc'
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.topMargin: 5

                Rectangle {
                    color: depthRect.color
                    radius: 21
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42

                    Rectangle {
                        color: parent.color
                        width: if (comment.depth > 0) { parent.width / 2 } else { 0 }
                        height: parent.height
                    }

                    Rectangle {
                        color: 'white'
                        width: parent.width - 2
                        height: parent.height - 2
                        radius: width / 2

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter

                        Avatar {
                            id: avatar
                            small: true
                        }
                    }
                }

                Text {
                    id: commenter
                    Layout.fillWidth: true
                    font.bold: true
                }
            }

            Text {
                id: body
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignJustify
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: parent.Layout.preferredWidth - Layout.leftMargin - 10
                Layout.leftMargin: depthRect.width * 2
                textFormat: Text.RichText
            }

            CommentReply {
                id: commentReply
                onClosed: comment.replyOpen = false
            }
        }
    }
}
