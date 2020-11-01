#![recursion_limit = "256"]

#[macro_use]
extern crate cstr;
#[macro_use]
extern crate cpp;
#[macro_use]
extern crate qmetaobject;

mod commands;
mod qobjects;
mod qrc;

use labrat::keys::{CommentReplyKey, FavKey, SubmissionsKey, ViewKey};
use labrat::resources::header::Header;
use labrat::resources::msg::submissions::Submissions;
use labrat::resources::view::View;

use qmetaobject::*;

use reqwest::header::HeaderValue;

use url::Url;

type ResponseResult = Result<Response, crate::commands::Error>;

#[derive(Debug)]
enum Response {
    View(labrat::client::Response<View>),
    Download,
    Login,
    Reply,
    Fav,
    Unfav,
    Submissions(labrat::client::Response<Submissions>),
    ClearSubmissions,
}

impl Response {
    fn header(&self) -> Option<&Header> {
        match self {
            Response::View(cr) => cr.header.as_ref(),
            Response::Submissions(cr) => cr.header.as_ref(),
            Response::Login => None,
            Response::Download => None,
            Response::Reply => None,            // TODO
            Response::Fav => None,              // TODO
            Response::Unfav => None,            // TODO
            Response::ClearSubmissions => None, // TODO
        }
    }
}

#[derive(Debug)]
enum Request {
    Login(HeaderValue),
    View(ViewKey),
    ClearSubmissions(Vec<ViewKey>),
    Download(Url, Url),
    Reply(CommentReplyKey, String),
    Fav(FavKey),
    Unfav(FavKey),
    Submissions(SubmissionsKey),
}

#[derive(Debug)]
struct Msg<T> {
    id: usize,
    content: T,
}

#[cfg(target_arch="arm")]
fn fix_scaling() {
    // Hack around non-integer scale factor on Ubuntu Touch
    std::env::set_var("QT_SCALE_FACTOR", "2");
}

#[cfg(not(target_arch="arm"))]
fn fix_scaling() {
    unsafe {
        cpp! { {
            #include <QtCore/QCoreApplication>
        }}
        cpp! {[]{
            QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        }}
    }
}

fn main() {
    fix_scaling();

    unsafe {
        cpp! { {
            #include <QtCore/QCoreApplication>
            #include <QtCore/QString>
        }}
        cpp! {[]{
            QCoreApplication::setApplicationName(QStringLiteral("labrat-ut.vypo.dev"));

            QCoreApplication::setOrganizationName(QStringLiteral("labrat-ut.vypo.dev"));
            QCoreApplication::setOrganizationDomain(QStringLiteral("."));

            QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
        }}
    }

    QQuickStyle::set_style("Suru");
    qrc::load();
    crate::qobjects::register();
    let mut engine = QmlEngine::new();
    let rat = crate::qobjects::Rat::default();
    let qrat = engine.new_qobject(rat);
    engine.set_property("Rat".into(), qrat.to_variant());
    engine.load_file("qrc:/qml/Main.qml".into());

    unsafe {
        cpp! { {
            #include <QtWebEngine/QtWebEngine>
        }}
        cpp! {[]{
            QtWebEngine::initialize();
        }}
    }

    engine.exec();
}
