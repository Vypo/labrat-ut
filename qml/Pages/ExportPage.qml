/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Item {
    id: picker
    property var activeTransfer
    property alias contentType: peerPicker.contentType

    property string url

    ContentPeerPicker {
        id: peerPicker
        visible: parent.visible
        showTitle: false
        handler: ContentHandler.Destination

        onPeerSelected: {
            picker.activeTransfer = peer.request();
            picker.activeTransfer.stateChanged.connect(function() {
                if (!picker.activeTransfer) { return; }

                if (picker.activeTransfer.state === ContentTransfer.InProgress) {
                    console.log("Export: In progress " + url);
                    picker.activeTransfer.items = [ resultComponent.createObject(root, {"url": url}) ];
                    picker.activeTransfer.state = ContentTransfer.Charged;
                    stack.pop()
                }
            })
        }

        onCancelPressed: {
            stack.pop()
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }

    Component {
        id: resultComponent

        ContentItem {}
    }
}
