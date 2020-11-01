import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

ToolButton {
    text: qsTr('⤓')
    onClicked: single.download(parent.downloadSource)

    SingleDownload {
        id: single
        onErrorMessageChanged: console.log(errorMessage)
        onProgressChanged: console.log('progress: ' + progress)
        onFinished: stack.push('../Pages/ExportPage.qml', {'url': 'file://' + path, 'contentType': ContentType.Pictures })
    }
}
