qrc!(qml_resources,
    "/" {
        "qml/Main.qml",

        "qml/Pages/Login.qml",
        "qml/Pages/View.qml",
        "qml/Pages/Journal.qml",
        "qml/Pages/ExportPage.qml",
        "qml/Pages/Submissions.qml",
        "qml/Pages/Welcome.qml",
        "qml/Pages/Journals.qml",

        "qml/Components/PageHeader.qml",
        "qml/Components/Avatar.qml",
        "qml/Components/CommentReply.qml",
        "qml/Components/Comment.qml",
        "qml/Components/DownloadButton.qml",
        "qml/Components/OverlayMenuButton.qml",
        "qml/Components/UtDownloadButton.qml",
        "qml/Components/DesktopDownloadButton.qml",
    },
);

pub fn load() {
    qml_resources();
}
