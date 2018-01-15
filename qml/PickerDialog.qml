import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.3

PopupBase {
    id: picker

    property var activeTransfer

    Rectangle {
        anchors.fill: parent

        ContentTransferHint {
            anchors.fill: parent
            activeTransfer: picker.activeTransfer
        }

        ContentPeerPicker {
            anchors.fill: parent
            visible: true
            contentType: ContentType.Pictures
            handler: ContentHandler.Source

            onPeerSelected: {
                if (model.allowMultipleFiles) {
                    peer.selectionType = ContentTransfer.Multiple
                } else {
                    peer.selectionType = ContentTransfer.Single
                }
                picker.activeTransfer = peer.request()
                stateChangeConnection.target = picker.activeTransfer
            }

            onCancelPressed: {
                model.reject()
            }
        }
    }

    Connections {
        id: stateChangeConnection
        target: null
        onStateChanged: {
            if (picker.activeTransfer.state === ContentTransfer.Charged) {
                var selectedItems = []
                for(var i in picker.activeTransfer.items) {
                    selectedItems.push(String(picker.activeTransfer.items[i].url).replace("file://", ""))
                }
                model.accept(selectedItems)
            }
        }
    }

    Component.onCompleted: {
        show()
    }
}
