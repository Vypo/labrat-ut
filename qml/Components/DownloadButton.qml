import QtQuick 2.7

Loader {
    property string downloadSource
    property bool reloaded

    source: 'UtDownloadButton.qml'
    onStatusChanged: {
        if (status === Loader.Error && !reloaded) {
            reloaded = true;
            source = 'DesktopDownloadButton.qml';
        }
    }
}
