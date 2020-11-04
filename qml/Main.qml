import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0
import Labrat 1.0

import "Components"
import "Pages"

ApplicationWindow {
    id: root
    objectName: 'stack'

    width: 800
    height: 600
    visible: true

    signal loginCompleted

    Item {
        id: menuOverlay
        anchors.fill: parent
        z: 10000
        visible: false

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.2

            MouseArea {
                anchors.fill: parent
                onClicked: menuOverlay.visible = false
                propagateComposedEvents: false
            }
        }

        Page {
            anchors {
                fill: parent
                leftMargin: root.width * 0.1
            }
            id: menuRect
            z: 10002

            ToolButton {
                anchors {
                    top: parent.top
                    right: parent.right
                }
                id: closeBtn
                text: "✕"
                width: height
                onClicked: menuOverlay.visible = false
            }

            OverlayMenuButton {
                anchors {
                    top: closeBtn.bottom
                    left: parent.left
                    right: parent.right
                }

                implicitWidth: parent.width
                id: subsBtn
                onClicked: controller0.fetchJournalById(6740803)
                count: controller0.header.submissions
                buttonText: qsTr("SUBMISSIONS")
                bubbleColor: "skyblue"
            }

            OverlayMenuButton {
                anchors {
                    top: subsBtn.bottom
                    left: parent.left
                    right: parent.right
                }

                implicitWidth: parent.width
                id: journalsBtn
                onClicked: controller0.fetchJournalById(6740803)
                count: controller0.header.journals
                buttonText: qsTr("JOURNALS")
                bubbleColor: "lightgreen"
            }

            OverlayMenuButton {
                anchors {
                    top: journalsBtn.bottom
                    left: parent.left
                    right: parent.right
                }

                implicitWidth: parent.width
                id: watchesBtn
                onClicked: controller0.fetchJournalById(6740803)
                count: controller0.header.watches + controller0.header.favorites + controller0.header.comments
                buttonText: qsTr("INTERACTIONS")
                bubbleColor: "orange"
            }

            OverlayMenuButton {
                anchors {
                    top: watchesBtn.bottom
                    left: parent.left
                    right: parent.right
                }

                implicitWidth: parent.width
                id: notesBtn
                onClicked: controller0.fetchJournalById(6740803)
                count: controller0.header.notes
                buttonText: qsTr("NOTES")
                bubbleColor: "orangered"
            }

            OverlayMenuButton {
                anchors {
                    top: notesBtn.bottom
                    left: parent.left
                    right: parent.right
                }

                implicitWidth: parent.width
                id: ticketsBtn
                onClicked: controller0.fetchJournalById(6740803)
                count: controller0.header.trouble_tickets
                buttonText: qsTr("TROUBLE TICKETS")
                bubbleColor: "black"
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: logoutBtn.top
                }
                onClicked: controller0.fetchJournalById(6740803)

                contentItem: Item {
                    Label {
                        anchors {
                            fill: parent
                            leftMargin: 50
                        }
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        text: "Journal"
                    }
                }
            }

            ToolButton {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                id: logoutBtn
                text: "Log Out"
                highlighted: true
                onClicked: {
                    controller0.credentials = new ArrayBuffer(0);
                    stack.replace(null, "Pages/Welcome.qml", {isWelcome: true});
                    menuOverlay.visible = false;
                }
            }
        }

        DropShadow {
            anchors.fill: menuRect
            radius: 10
            samples: 10
            z: 10001
            source: menuRect
        }

    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: qsTr("Labrat")
            avatar: controller0.header.user.avatar
        }

        Settings {
            property alias credentials: controller0.credentials
        }

        StackView {
            property bool initial: true

            id: stack
            anchors.fill: parent
            initialItem: "Pages/Welcome.qml"
        }

        RatController {
            id: controller0
            onError: console.log(msg)
            onJournalFetched: stack.push(journalView, {"content": journal})
            onViewFetched: stack.push(viewView, {"content": view})
            onSubmissionsFetched: if (stack.currentItem.isWelcome) {
                stack.replace(null, submissionsView, {"content": submissions})
            } else {
                stack.push(submissionsView, {"content": submissions})
            }
            onLoginCompleted: stack.pop()

            onCredentialsChanged: if (credentials.byteLength > 0) {
                controller0.fetchSubmissions(Rat.Oldest)
            }

            Component.onCompleted: controller0.start()
        }

        Component {
            id: submissionsView

            Submissions {
            }
        }

        Component {
            id: journalView

            Journal {
            }
        }

        Component {
            id: viewView

            View {
            }
        }

        Component {
            id: loginView

            Login {
                controller: controller0
            }
        }

        Component {
            id: mainView

            ColumnLayout {
                spacing: 2

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    id: label
                    text: qsTr('Press the button below!')
                }

                TextField {
                    id: textBox
                }

                Button {
                    text: qsTr('View!')
                    onClicked: controller0.fetchViewById(textBox.text)
                }

                Button {
                    text: qsTr('Login!')
                    onClicked: stack.push(loginView)
                }

                Button {
                    text: qsTr('Submissions')
                    onClicked: controller0.fetchSubmissions(Rat.Oldest)
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

    }
}
