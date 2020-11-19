#![allow(non_snake_case)]

use labrat::client::Client;
use labrat::keys::{
    CommentReplyKey, FavKey, JournalKey, SubmissionsKey, ViewKey,
};
use labrat::resources::comment::CommentContainer;
use labrat::resources::header::{Header, Notifications};
use labrat::resources::journal::Journal;
use labrat::resources::msg::others::{MiniJournal, Others};
use labrat::resources::msg::submissions::Submissions;
use labrat::resources::view::View;
use labrat::resources::{MiniUser, PreviewSize, Submission};

use qmetaobject::*;

use reqwest::header::HeaderValue;

use super::{Msg, Request, Response, ResponseResult};

use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap};
use std::convert::TryFrom;
use std::sync::Arc;

use tokio::sync::mpsc::{self, UnboundedReceiver, UnboundedSender};

use url::Url;

#[derive(Debug, Default, QGadget, Clone)]
pub struct RatJournalKey(Option<JournalKey>);

#[derive(
    Debug, Default, QGadget, Clone, Hash, PartialEq, Eq, Ord, PartialOrd,
)]
pub struct RatViewKey(Option<ViewKey>);

#[derive(QObject, Default)]
pub struct RatMiniUser {
    base: qt_base_class!(trait QObject),

    avatar: qt_property!(QString; NOTIFY avatarChanged READ get_avatar),
    avatarChanged: qt_signal!(),

    name: qt_property!(String; NOTIFY nameChanged READ get_name),
    nameChanged: qt_signal!(),

    slug: qt_property!(String; NOTIFY slugChanged READ get_slug),
    slugChanged: qt_signal!(),

    user: Option<MiniUser>,
}

impl RatMiniUser {
    fn set(&mut self, user: MiniUser) {
        self.user = Some(user);
        self.avatarChanged();
        self.nameChanged();
        self.slugChanged();
    }

    fn get_avatar(&self) -> QString {
        self.user
            .as_ref()
            .map(|u| QString::from(u.avatar().as_str()))
            .unwrap_or_default()
    }

    fn get_name(&self) -> String {
        self.user
            .as_ref()
            .map(|u| u.name().to_string())
            .unwrap_or_default()
    }

    fn get_slug(&self) -> String {
        self.user
            .as_ref()
            .map(|u| u.slug().to_string())
            .unwrap_or_default()
    }
}

#[derive(QObject, Default)]
pub struct RatHeader {
    base: qt_base_class!(trait QObject),
    user: qt_property!(RefCell<RatMiniUser>; NOTIFY userChanged),
    userChanged: qt_signal!(),

    submissions: qt_property!(u64; NOTIFY submissionsChanged READ get_submissions),
    submissionsChanged: qt_signal!(),
    journals: qt_property!(u64; NOTIFY journalsChanged READ get_journals),
    journalsChanged: qt_signal!(),
    watches: qt_property!(u64; NOTIFY watchesChanged READ get_watches),
    watchesChanged: qt_signal!(),
    comments: qt_property!(u64; NOTIFY commentsChanged READ get_comments),
    commentsChanged: qt_signal!(),
    favorites: qt_property!(u64; NOTIFY favoritesChanged READ get_favorites),
    favoritesChanged: qt_signal!(),
    notes: qt_property!(u64; NOTIFY notesChanged READ get_notes),
    notesChanged: qt_signal!(),
    trouble_tickets: qt_property!(
        u64; NOTIFY troubleTicketsChanged READ get_trouble_tickets
    ),
    troubleTicketsChanged: qt_signal!(),

    notifications: Option<Notifications>,
}

impl RatHeader {
    fn set(&mut self, header: Header) {
        self.user.borrow_mut().set(header.me().clone());

        self.notifications = Some(header.notifications().clone());
        self.submissionsChanged();
        self.journalsChanged();
        self.watchesChanged();
        self.commentsChanged();
        self.favoritesChanged();
        self.notesChanged();
        self.troubleTicketsChanged();
    }

    fn get_submissions(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.submissions)
            .unwrap_or_default()
    }

    fn get_journals(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.journals)
            .unwrap_or_default()
    }

    fn get_watches(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.watches)
            .unwrap_or_default()
    }

    fn get_comments(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.comments)
            .unwrap_or_default()
    }

    fn get_favorites(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.favorites)
            .unwrap_or_default()
    }

    fn get_notes(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.notes)
            .unwrap_or_default()
    }

    fn get_trouble_tickets(&self) -> u64 {
        self.notifications
            .as_ref()
            .map(|h| h.trouble_tickets)
            .unwrap_or_default()
    }
}

#[derive(Debug, Default, SimpleListItem)]
pub struct ListJournal {
    pub key: RatJournalKey,

    pub author_avatar: QString,
    pub author_name: String,
    pub author_slug: String,

    pub title: String,
}

impl From<&MiniJournal> for ListJournal {
    fn from(j: &MiniJournal) -> Self {
        Self {
            key: RatJournalKey(Some(j.into())),

            author_avatar: QString::from(j.author().avatar().as_str()),
            author_name: j.author().name().to_string(),
            author_slug: j.author().name().to_string(),

            title: j.title().to_string(),
        }
    }
}

#[derive(Debug, Default, SimpleListItem)]
pub struct ListSubmission {
    pub key: RatViewKey,

    pub artist_avatar: QString,
    pub artist_name: String,
    pub artist_slug: String,

    pub rating: String,
    pub title: String,
    pub description: String,

    pub preview: QString,
}

impl From<&Submission> for ListSubmission {
    fn from(s: &Submission) -> Self {
        Self {
            key: RatViewKey(Some(s.into())),

            artist_avatar: QString::from(s.artist().avatar().as_str()),
            artist_name: s.artist().name().to_string(),
            artist_slug: s.artist().name().to_string(),

            description: s.description().to_string(),
            title: s.title().to_string(),
            rating: s.rating().to_string(),

            preview: QString::from(s.preview(PreviewSize::Xxxl).as_str()),
        }
    }
}

#[derive(Debug, Default, SimpleListItem)]
pub struct ListComment {
    pub exists: bool,
    pub depth: u8,

    pub commenter_avatar: QString,
    pub commenter_name: String,
    pub commenter_slug: String,

    pub text: String,

    pub replyKey: RatReply,
}

impl From<&CommentContainer> for ListComment {
    fn from(cc: &CommentContainer) -> Self {
        let comment = match cc.comment() {
            None => {
                return Self {
                    depth: cc.depth(),
                    ..Default::default()
                }
            }
            Some(c) => c,
        };

        Self {
            exists: true,
            depth: cc.depth(),

            commenter_avatar: comment.commenter().avatar().to_string().into(),
            commenter_name: comment.commenter().name().to_string(),
            commenter_slug: comment.commenter().slug().to_string(),

            text: comment.text().to_string(),

            replyKey: RatReply(Some(cc.into())),
        }
    }
}

#[derive(QObject, Default)]
pub struct RatJournal {
    base: qt_base_class!(trait QObject),
    title: qt_property!(String; READ get_title NOTIFY titleChanged),
    titleChanged: qt_signal!(),
    author: qt_property!(RefCell<RatMiniUser>; NOTIFY authorChanged),
    authorChanged: qt_signal!(),
    commentsChanged: qt_signal!(),
    comments: qt_property!(
        RefCell<SimpleListModel<ListComment>>; NOTIFY commentsChanged
    ),
    header: qt_property!(String; READ get_header NOTIFY headerChanged),
    headerChanged: qt_signal!(),
    footer: qt_property!(String; READ get_footer NOTIFY footerChanged),
    footerChanged: qt_signal!(),
    content: qt_property!(String; READ get_content NOTIFY contentChanged),
    contentChanged: qt_signal!(),
    replyKey: qt_property!(RatReply; NOTIFY replyKeyChanged READ get_reply_key),
    replyKeyChanged: qt_signal!(),

    journal: Option<Journal>,
}

impl RatJournal {
    fn get_reply_key(&self) -> RatReply {
        match &self.journal {
            Some(v) => RatReply(Some(v.into())),
            None => RatReply::default(),
        }
    }

    fn get_header(&self) -> String {
        self.journal
            .as_ref()
            .and_then(Journal::header)
            .map(String::from)
            .unwrap_or_default()
    }

    fn get_footer(&self) -> String {
        self.journal
            .as_ref()
            .and_then(Journal::footer)
            .map(String::from)
            .unwrap_or_default()
    }

    fn get_content(&self) -> String {
        self.journal
            .as_ref()
            .map(Journal::content)
            .map(String::from)
            .unwrap_or_default()
    }

    fn get_title(&self) -> String {
        self.journal
            .as_ref()
            .map(Journal::title)
            .map(String::from)
            .unwrap_or_default()
    }

    fn set(&mut self, journal: Journal) {
        let comments =
            journal.comments().iter().map(ListComment::from).collect();

        self.author.borrow_mut().set(journal.author().clone());
        self.journal = Some(journal);
        self.titleChanged();
        self.replyKeyChanged();
        self.headerChanged();
        self.footerChanged();
        self.contentChanged();

        let mut qcomments = self.comments.borrow_mut();
        qcomments.reset_data(comments);
    }
}

#[derive(QObject, Default)]
pub struct RatView {
    base: qt_base_class!(trait QObject),
    download: qt_property!(QString; READ get_download NOTIFY downloadChanged),
    downloadChanged: qt_signal!(),
    fullview: qt_property!(QString; READ get_fullview NOTIFY fullviewChanged),
    fullviewChanged: qt_signal!(),
    title: qt_property!(String; READ get_title NOTIFY titleChanged),
    titleChanged: qt_signal!(),
    description: qt_property!(String; READ get_description NOTIFY descriptionChanged),
    descriptionChanged: qt_signal!(),
    artist: qt_property!(RefCell<RatMiniUser>; NOTIFY artistChanged),
    artistChanged: qt_signal!(),

    commentsChanged: qt_signal!(),
    comments: qt_property!(
        RefCell<SimpleListModel<ListComment>>; NOTIFY commentsChanged
    ),

    replyKey: qt_property!(RatReply; NOTIFY replyKeyChanged READ get_reply_key),
    replyKeyChanged: qt_signal!(),

    showFav: qt_property!(bool; NOTIFY showFavChanged READ get_show_fav),
    showFavChanged: qt_signal!(),

    showUnfav: qt_property!(bool; NOTIFY showUnfavChanged READ get_show_unfav),
    showUnfavChanged: qt_signal!(),

    favKey: qt_property!(RatFav; NOTIFY favKeyChanged READ get_fav_key),
    favKeyChanged: qt_signal!(),

    view: Option<View>,
}

impl RatView {
    fn set(&mut self, view: View) {
        let comments = view.comments().iter().map(ListComment::from).collect();

        self.artist
            .borrow_mut()
            .set(view.submission().artist().clone());
        self.view = Some(view);
        self.fullviewChanged();
        self.titleChanged();
        self.replyKeyChanged();
        self.favKeyChanged();
        self.showFavChanged();
        self.showUnfavChanged();

        let mut qcomments = self.comments.borrow_mut();
        qcomments.reset_data(comments);
    }

    fn get_show_unfav(&self) -> bool {
        self.view
            .as_ref()
            .and_then(|v| v.faved())
            .unwrap_or_default()
    }

    fn get_show_fav(&self) -> bool {
        self.view
            .as_ref()
            .and_then(|v| v.faved())
            .map(|x| !x)
            .unwrap_or_default()
    }

    fn get_fav_key(&self) -> RatFav {
        match self.view.as_ref().and_then(|v| FavKey::try_from(v).ok()) {
            Some(v) => RatFav(Some(v.clone())),
            None => RatFav::default(),
        }
    }

    fn get_reply_key(&self) -> RatReply {
        match &self.view {
            Some(v) => RatReply(Some(v.into())),
            None => RatReply::default(),
        }
    }

    fn get_download(&self) -> QString {
        match self.view.as_ref() {
            Some(v) => v.download().to_string().into(),
            None => QString::default(),
        }
    }

    fn get_description(&self) -> String {
        match self.view.as_ref() {
            Some(v) => v.submission().description().to_string(),
            None => String::default(),
        }
    }

    fn get_title(&self) -> String {
        match self.view.as_ref() {
            Some(v) => v.submission().title().to_string(),
            None => String::default(),
        }
    }

    fn get_fullview(&self) -> QString {
        match self.view.as_ref() {
            Some(v) => v.fullview().to_string().into(),
            None => QString::default(),
        }
    }
}

impl From<View> for RatView {
    fn from(h: View) -> RatView {
        let mut q = RatView::default();
        q.view = Some(h);
        q
    }
}

#[derive(QObject, Default)]
pub struct RatSubmissions {
    base: qt_base_class!(trait QObject),
    model: qt_property!(
        RefCell<SimpleListModel<ListSubmission>>; NOTIFY modelChanged
    ),
    modelChanged: qt_signal!(),
    next: qt_property!(RatSubs; NOTIFY nextChanged),
    nextChanged: qt_signal!(),
    prev: qt_property!(RatSubs; NOTIFY prevChanged),
    prevChanged: qt_signal!(),
    remove: qt_method!(
        fn remove(&mut self, key: RatViewKey) {
            let mut items = self.model.borrow_mut();
            for idx in 0..items.row_count() {
                if items[idx as usize].key.0 == key.0 {
                    items.remove(idx as usize);
                    break;
                }
            }
        }
    ),
}

impl RatSubmissions {
    fn merge(&mut self, page: Submissions) {
        if page.prev().map(|p| p < &self.prev.0).unwrap_or(false) {
            self.prev.0 = page.prev().unwrap().clone();
            self.prevChanged();
        }

        if page.next().map(|n| n > &self.next.0).unwrap_or(false) {
            self.next.0 = page.next().unwrap().clone();
            self.nextChanged();
        }

        let mut subs: BTreeMap<_, _> = page
            .into_items()
            .iter()
            .map(ListSubmission::from)
            .map(|s| (s.key.clone(), s))
            .collect();

        let mut qsubs = self.model.borrow_mut();

        for idx in 0..qsubs.row_count() {
            let key = qsubs[idx as usize].key.clone();
            if let Some(existing) = subs.remove(&key) {
                qsubs.change_line(idx as usize, existing);
            }
        }

        for (_, sub) in subs.into_iter() {
            qsubs.push(sub);
        }
    }

    fn clear(&mut self) {
        self.model.borrow_mut().reset_data(vec![]);
    }
}

#[derive(QObject, Default)]
pub struct RatJournals {
    base: qt_base_class!(trait QObject),
    model: qt_property!(
        RefCell<SimpleListModel<ListJournal>>; NOTIFY modelChanged
    ),
    modelChanged: qt_signal!(),
}

impl RatJournals {
    fn set(&mut self, page: Others) {
        let jrnls: Vec<_> =
            page.journals().iter().map(ListJournal::from).collect();

        let mut qjrnls = self.model.borrow_mut();
        qjrnls.reset_data(jrnls);
    }
}

#[derive(Debug, Clone, QGadget, Default)]
pub struct RatReply(Option<CommentReplyKey>);

#[derive(Debug, Clone, QGadget, Default)]
pub struct RatFav(Option<FavKey>);

#[derive(Debug, Clone, QGadget)]
pub struct RatSubs(SubmissionsKey);

impl Default for RatSubs {
    fn default() -> Self {
        RatSubs(SubmissionsKey::oldest())
    }
}

#[derive(QObject, Default)]
pub struct RatController {
    base: qt_base_class!(trait QObject),
    error: qt_signal!(msg: String),
    header: qt_property!(RefCell<RatHeader>; NOTIFY headerChanged), // TODO: make this read-only
    headerChanged: qt_signal!(),
    submissions: qt_property!(
        RefCell<RatSubmissions>; NOTIFY submissionsChanged
    ), // TODO: make this read-only
    journals: qt_property!(
        RefCell<RatJournals>; NOTIFY othersChanged
    ), // TODO: make this read-only
    othersChanged: qt_signal!(),
    view: qt_property!(RefCell<RatView>; NOTIFY viewFetched), // TODO: make this read-only
    journal: qt_property!(RefCell<RatJournal>; NOTIFY journalFetched), // TODO: make this read-only
    credentials: qt_property!(QByteArray; NOTIFY credentialsChanged READ get_credentials WRITE set_credentials),
    credentialsChanged: qt_signal!(),
    loginCompleted: qt_signal!(),
    submissionsChanged: qt_signal!(),
    submissionsFetched: qt_signal!(),
    viewFetched: qt_signal!(),
    journalFetched: qt_signal!(),
    unfavCompleted: qt_signal!(),
    unfav: qt_method!(
        fn unfav(&mut self, key: RatFav) {
            if let Some(key) = key.0 {
                self.send(Request::Unfav(key));
            }
        }
    ),
    favCompleted: qt_signal!(),
    fav: qt_method!(
        fn fav(&mut self, key: RatFav) {
            if let Some(key) = key.0 {
                self.send(Request::Fav(key));
            }
        }
    ),
    replyCompleted: qt_signal!(),
    reply: qt_method!(
        fn reply(&mut self, to: RatReply, text: String) {
            if let Some(key) = to.0 {
                self.send(Request::Reply(key, text));
            }
        }
    ),
    fetchViewById: qt_method!(
        fn fetchViewById(&mut self, view_id: u64) {
            self.fetchView(RatViewKey(Some(ViewKey { view_id })));
        }
    ),
    fetchView: qt_method!(
        fn fetchView(&mut self, view: RatViewKey) {
            let content = Request::View(view.0.unwrap());
            self.send(content);
        }
    ),
    clearSubmission: qt_method!(
        fn clearSubmission(&mut self, view: RatViewKey) {
            let content = Request::ClearSubmissions(vec![view.0.unwrap()]);
            self.send(content);
        }
    ),
    fetchJournal: qt_method!(
        fn fetchJournal(&mut self, journal: RatJournalKey) {
            let content = Request::Journal(journal.0.unwrap());
            self.send(content);
        }
    ),
    fetchJournalById: qt_method!(
        fn fetchJournalById(&mut self, journal_id: u64) {
            self.fetchJournal(RatJournalKey(Some(JournalKey { journal_id })));
        }
    ),
    fetchOthers: qt_method!(
        fn fetchOthers(&mut self) {
            if self.worker.is_none() {
                self.start();
            }

            self.send(Request::Others);
        }
    ),
    fetchSubmissions: qt_method!(
        fn fetchSubmissions(&mut self, key: RatSubs) {
            if self.worker.is_none() {
                self.start();
            }

            self.send(Request::Submissions(key.0));
        }
    ),
    start: qt_method!(
        fn start(&mut self) {
            if self.worker.is_some() {
                return;
            }

            let (sender, receiver) = mpsc::unbounded_channel();
            self.worker = Some(sender);

            let pointer = QPointer::from(&*self);
            let cb = queued_callback(move |reply: Msg<ResponseResult>| {
                if let Some(cell) = pointer.as_pinned() {
                    let controller = cell.borrow_mut();

                    if reply.id != controller.current_request - 1 {
                        return;
                    }

                    let content = match reply.content {
                        Ok(c) => c,
                        Err(e) => {
                            controller.error(e.to_string());
                            return;
                        }
                    };

                    if let Some(header) = content.header() {
                        controller.header.borrow_mut().set(header.clone());
                    }

                    match content {
                        Response::Login => {
                            controller.loginCompleted();
                        }
                        Response::Others(o) => {
                            controller.journals.borrow_mut().set(o.page);
                            controller.othersChanged();
                        }
                        Response::Submissions(s) => {
                            {
                                let mut subs =
                                    controller.submissions.borrow_mut();
                                if s.page.prev().is_none() {
                                    subs.clear();
                                }
                                subs.merge(s.page);
                            }
                            controller.submissionsFetched();
                        }
                        Response::ClearSubmissions => {}
                        Response::Journal(v) => {
                            controller.journal.borrow_mut().set(v.page);
                            controller.journalFetched();
                        }
                        Response::View(v) => {
                            controller.view.borrow_mut().set(v.page);
                            controller.viewFetched();
                        }
                        Response::Download => {
                            controller.downloadCompleted();
                        }
                        Response::Reply => {
                            controller.replyCompleted();
                        }
                        Response::Fav(view) => {
                            controller.favCompleted();
                            controller.update_live_view(view.page);
                        }
                        Response::Unfav(view) => {
                            controller.unfavCompleted();
                            controller.update_live_view(view.page);
                        }
                    }
                }
            });

            let credentials = self.credentials.clone();
            std::thread::spawn(move || Self::run(credentials, receiver, cb));
        }
    ),

    downloadCompleted: qt_signal!(),
    download: qt_method!(
        fn download(&mut self, src: QString, dst: QString) {
            let src = Url::parse(&src.to_string()).unwrap();
            let dst = Url::parse(&dst.to_string()).unwrap();
            self.send(Request::Download(src, dst))
        }
    ),

    worker: Option<UnboundedSender<Msg<Request>>>,
    current_request: usize,
}

impl RatController {
    async fn run_async<F>(
        credentials: QByteArray,
        mut commands: UnboundedReceiver<Msg<Request>>,
        f: F,
    ) where
        F: 'static + Fn(Msg<ResponseResult>) + Send + Sync + Clone,
    {
        let slice = credentials.to_slice();

        let client = if slice.is_empty() {
            Arc::new(Client::new().unwrap())
        } else {
            let header = HeaderValue::from_bytes(slice).unwrap();
            Arc::new(Client::with_cookies(header).unwrap())
        };

        while let Some(msg) = commands.recv().await {
            let reply_cb = f.clone();
            let client_clone = client.clone();
            tokio::task::spawn(async move {
                let id = msg.id;
                let content =
                    crate::commands::command(client_clone, msg.content).await;
                reply_cb(Msg { id, content });
            });
        }
    }

    fn run<F>(
        credentials: QByteArray,
        commands: UnboundedReceiver<Msg<Request>>,
        f: F,
    ) where
        F: 'static + Fn(Msg<ResponseResult>) + Send + Sync + Clone,
    {
        let mut runtime = tokio::runtime::Runtime::new().unwrap();
        runtime.block_on(Self::run_async(credentials, commands, f));
    }

    fn send(&mut self, content: Request) {
        let worker = match self.worker.as_mut() {
            Some(w) => w,
            None => return,
        };

        let id = self.current_request;
        self.current_request += 1;

        if worker.send(Msg { id, content }).is_err() {
            panic!("worker thread died");
        }
    }

    fn update_live_view(&self, view: View) {
        let mut live_rat_view = self.view.borrow_mut();
        let replace = match &live_rat_view.view {
            Some(live_view) => {
                let new_key = ViewKey::from(&view);
                let old_key = ViewKey::from(live_view);
                new_key == old_key
            }
            None => false,
        };

        if replace {
            live_rat_view.set(view);
        }
    }

    fn get_credentials(&self) -> QByteArray {
        self.credentials.clone()
    }

    fn set_credentials(&mut self, value: QByteArray) {
        if value.to_slice().len() == 0 {
            *self.header.borrow_mut() = RatHeader::default();
            self.headerChanged();
        }

        let header = HeaderValue::from_bytes(value.to_slice()).unwrap();

        self.credentials = value;
        self.send(Request::Login(header));

        self.credentialsChanged();
    }
}

#[derive(QObject, Default)]
struct RatSpy {
    base: qt_base_class!(trait QObject),

    controller: qt_property!(QPointer<RatController>),

    cookie: qt_method!(
        fn cookie(&self, domain: QString, name: QString, value: QByteArray) {
            let domain: String = domain.into();
            let name: String = name.into();
            if !domain.ends_with(".furaffinity.net") {
                return;
            }

            let mut cookies = self.cookies.borrow_mut();
            let value_vec = Vec::from(value.to_slice());
            cookies.insert(name, value_vec);
        }
    ),

    url: qt_method!(
        fn url(&self, url: QString) {
            let url: String = url.into();

            if url == "https://www.furaffinity.net/" {
                let mut cookies = self.cookies.borrow_mut();

                if cookies.contains_key("a") && cookies.contains_key("b") {
                    let pinned = self.controller.as_pinned().unwrap();
                    let mut controller = pinned.borrow_mut();

                    let mut bytes: Vec<u8> = cookies
                        .drain()
                        .flat_map(|(key, value)| {
                            let mut output =
                                Vec::with_capacity(key.len() + value.len() + 3);

                            output.extend_from_slice(key.as_bytes());
                            output.push(b'=');
                            output.extend(value);
                            output.extend_from_slice(b"; ");

                            output
                        })
                        .collect();

                    // Remove extra "; "
                    bytes.pop();
                    bytes.pop();

                    let qbytes = QByteArray::from(bytes.as_slice());
                    controller.set_credentials(qbytes);
                }
            }
        }
    ),

    created: qt_method!(
        fn created(&self, mut variant: QVariant) {
            let me_ptr = self.get_cpp_object();
            let var_ptr = &mut variant as *mut QVariant;

            unsafe {
                cpp! { {
                    #include <QtWebEngine/QtWebEngine>
                    #include <QtWebEngine/QQuickWebEngineProfile>
                }}
                cpp! {[var_ptr as "QVariant*", me_ptr as "QObject*"] {
                    if (!var_ptr->canConvert<QObject*>()) {
                        abort();
                    }

                    QObject* obj = var_ptr->value<QObject*>();
                    QQuickWebEngineProfile* profile =
                        qobject_cast<QQuickWebEngineProfile*>(obj);

                    if (!profile) { abort(); }

                    QWebEngineCookieStore* cookie_store =
                        profile->cookieStore();

                    cookie_store->deleteAllCookies();

                    auto handler = [=](const QNetworkCookie &cookie) {
                        QMetaObject::invokeMethod(
                            me_ptr,
                            "cookie",
                            Qt::AutoConnection,
                            Q_ARG(QString, cookie.domain()),
                            Q_ARG(QString, cookie.name()),
                            Q_ARG(QByteArray, cookie.value())
                        );
                    };

                    QObject::connect(
                        cookie_store,
                        &QWebEngineCookieStore::cookieAdded,
                        me_ptr,
                        handler
                    );
                }}
            }
        }
    ),

    cookies: RefCell<HashMap<String, Vec<u8>>>,
}

#[derive(QObject, Default)]
pub struct Rat {
    base: qt_base_class!(trait QObject),
    Newest: qt_property!(RatSubs; READ get_newest),
    Oldest: qt_property!(RatSubs; READ get_oldest),
}

impl Rat {
    fn get_oldest(&self) -> RatSubs {
        RatSubs(SubmissionsKey::oldest())
    }

    fn get_newest(&self) -> RatSubs {
        RatSubs(SubmissionsKey::newest())
    }
}

#[derive(QObject, Default)]
pub struct RatDownload {
    base: qt_base_class!(trait QObject),
    source: qt_property!(String; NOTIFY sourceChanged),
    sourceChanged: qt_signal!(),
    destination: qt_property!(QString; NOTIFY destinationChanged),
    destinationChanged: qt_signal!(),

    completed: qt_signal!(),
    error: qt_signal!(error: String),
}

pub fn register() {
    let uri = cstr!("Labrat");

    qml_register_type::<RatController>(uri, 1, 0, cstr!("RatController"));
    qml_register_type::<RatView>(uri, 1, 0, cstr!("RatView"));
    qml_register_type::<RatJournal>(uri, 1, 0, cstr!("RatJournal"));
    qml_register_type::<RatHeader>(uri, 1, 0, cstr!("RatHeader"));
    qml_register_type::<RatSpy>(uri, 1, 0, cstr!("RatSpy"));
    qml_register_type::<RatMiniUser>(uri, 1, 0, cstr!("RatMiniUser"));
    qml_register_type::<RatSubmissions>(uri, 1, 0, cstr!("RatSubmissions"));
    qml_register_type::<RatJournals>(uri, 1, 0, cstr!("RatJournals"));
}
