import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.0

ToolButton {
    id: dlBtn
    text: qsTr('⤓')
    onClicked: fileDialog.visible = true

    FileDialog {
        id: fileDialog
        title: "Save As"
        folder: shortcuts.home
        selectExisting: false
        onAccepted: controller0.download(dlBtn.parent.downloadSource, fileDialog.fileUrl)
    }
}
