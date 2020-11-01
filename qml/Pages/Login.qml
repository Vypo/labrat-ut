import QtQuick 2.7
import QtWebEngine 1.8
import Labrat 1.0

WebEngineView {
    // TODO: Use /login/?ref=https://www.furaffinity.net/view/1/ to navigate to a special page?
    url: 'https://www.furaffinity.net/login'

    property bool isWelcome: true
    property alias controller: spy.controller

    RatSpy {
        id: spy
    }

    WebEngineProfile {
        offTheRecord: true
    }

    onLoadingChanged: spy.url(loadRequest.url)
    Component.onCompleted: spy.created(profile)
}
