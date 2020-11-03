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

            ColumnLayout {
                anchors.fill: parent

                Button {
                    text: "✕"
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    onClicked: menuOverlay.visible = false
                }

                Button {
                    text: "Log Out"
                    highlighted: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    onClicked: {
                        controller0.credentials = new ArrayBuffer(0);
                        stack.replace(null, "Pages/Welcome.qml", {isWelcome: true});
                        menuOverlay.visible = false;
                    }
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
