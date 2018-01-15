import QtQuick 2.4
import Ubuntu.Web 0.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.3
import com.canonical.Oxide 1.0 as Oxide
import BlobSaver 1.0

MainView {
    id: root
    objectName: 'mainView'

    applicationName: 'photopea.bhdouglass'

    anchorToKeyboard: true
    automaticOrientation: true

    property string urlPattern: 'https?://www.photopea.com/*'

    width: units.gu(50)
    height: units.gu(75)

    Page {
        id: page
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        header: PageHeader {
            id: header
            visible: false
        }

        WebContext {
            id: webcontext
            userAgent: 'Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36 Ubuntu Touch Webapp'
            userScripts: [
                BlobSaverUserScript {}
            ]
        }

        WebView {
            id: webview
            anchors {
                fill: parent
                bottom: parent.bottom
            }
            width: parent.width
            height: parent.height

            context: webcontext
            url: 'https://www.photopea.com/'
            preferences.localStorageEnabled: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true

            function navigationRequestedDelegate(request) {
                var url = request.url.toString();
                var pattern = urlPattern.split(',');
                var isvalid = false;

                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)');
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');

                    if (url.match(search)) {
                       isvalid = true;
                       break;
                    }
                }

                if (isvalid == false) {
                    Qt.openUrlExternally(url);
                    request.action = Oxide.NavigationRequest.ActionReject;
                }
            }

            messageHandlers: [
                BlobSaverScriptMessageHandler {
                    cb: function(path) {
                        PopupUtils.open(openDialogComponent, root, {'path': path});
                    }
                }
            ]

            filePicker: pickerComponent

            Component.onCompleted: {
                preferences.localStorageEnabled = true;
            }
        }

        ProgressBar {
            height: units.dp(3)
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            showProgressPercentage: false
            value: (webview.loadProgress / 100)
            visible: (webview.loading && !webview.lastLoadStopped)
        }
    }

    Component {
        id: openDialogComponent

        OpenDialog {
            anchors.fill: parent
        }
    }

    Component {
        id: pickerComponent

        PickerDialog {}
    }
}
