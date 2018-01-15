import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.3
import BlobSaver 1.0

PopupBase {
    id: openDialog
    property var activeTransfer
    property var path

    Rectangle {
        anchors.fill: parent

        ContentItem {
            id: exportItem
        }

        ContentPeerPicker {
            visible: openDialog.visible
            handler: ContentHandler.Destination
            contentType: ContentType.Pictures

            onPeerSelected: {
                activeTransfer = peer.request();
                var items = [];
                exportItem.url = path;
                console.log(path);
                items.push(exportItem);
                activeTransfer.items = items;
                activeTransfer.state = ContentTransfer.Charged;

                BlobSaver.remove(path);
                PopupUtils.close(openDialog)
            }

            onCancelPressed: {
                BlobSaver.remove(path);
                PopupUtils.close(openDialog)
            }
        }
    }
}
