import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

RowLayout {
    property bool small: false
    property alias source: img.source

    onSmallChanged: {
        if (small) {
            img.Layout.preferredWidth = 36
            img.Layout.preferredHeight = 36
        } else {
            img.Layout.preferredWidth = 66
            img.Layout.preferredHeight = 66
        }
    }

    AnimatedImage {
        id: img
        autoTransform: true
        Layout.preferredWidth: 66
        Layout.preferredHeight: 66
        fillMode: Image.PreserveAspectCrop
        Layout.margins: 2
        clip: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
    }

    Rectangle {
        id: mask
        width: img.width
        height: img.height
        radius: img.width / 2
        visible: false
    }
}
