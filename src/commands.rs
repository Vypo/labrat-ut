mod error {
    use snafu::Snafu;

    use std::convert::Infallible;

    #[derive(Debug, Snafu)]
    #[snafu(visibility = "pub(crate)")]
    pub enum Error {
        Client {
            source: labrat::client::ClientError,
        },
        Request {
            source: labrat::client::RequestError<Infallible>,
        },
        Reqwest {
            source: reqwest::Error,
        },
        Io {
            source: std::io::Error,
        },
    }
}

use labrat::client::Client;
use labrat::keys::{
    CommentReplyKey, FavKey, JournalKey, SubmissionsKey, ViewKey,
};

use reqwest::header::HeaderValue;

pub use self::error::Error;

use snafu::ResultExt;

use std::sync::Arc;

use super::{Request, Response, ResponseResult};

use tokio::stream::StreamExt;

use url::Url;

pub(crate) async fn command(
    client: Arc<Client>,
    req: Request,
) -> ResponseResult {
    match req {
        Request::ClearSubmissions(keys) => {
            clear_submissions(client, keys).await
        }
        Request::Submissions(key) => submissions(client, key).await,
        Request::View(key) => view(client, key).await,
        Request::Journal(key) => journal(client, key).await,
        Request::Login(v) => login(client, v).await,
        Request::Fav(k) => fav(client, k).await,
        Request::Unfav(k) => unfav(client, k).await,
        Request::Reply(key, text) => reply(client, key, text).await,
        Request::Download(source, destination) => {
            download(source, destination).await
        }
    }
}

async fn clear_submissions(
    client: Arc<Client>,
    keys: Vec<ViewKey>,
) -> ResponseResult {
    client
        .clear_submissions(keys)
        .await
        .context(error::Request)?;
    Ok(Response::ClearSubmissions)
}

async fn submissions(
    client: Arc<Client>,
    key: SubmissionsKey,
) -> ResponseResult {
    let response = client.submissions(key).await.context(error::Request)?;
    Ok(Response::Submissions(response))
}

async fn reply(
    client: Arc<Client>,
    key: CommentReplyKey,
    text: String,
) -> ResponseResult {
    client.reply(key, &text).await.context(error::Request)?;
    Ok(Response::Reply)
}

async fn download(source: Url, destination: Url) -> ResponseResult {
    assert_eq!(destination.scheme(), "file");

    let destination = destination.to_file_path().unwrap();
    let mut outfile = tokio::fs::File::create(destination)
        .await
        .context(error::Io)?;

    let resp = reqwest::get(source).await.context(error::Reqwest)?;
    let mut body = resp.bytes_stream();

    while let Some(result) = body.next().await {
        let block = match result {
            Ok(b) => b,
            Err(source) => return Err(Error::Reqwest { source }),
        };

        tokio::io::copy(&mut block.as_ref(), &mut outfile)
            .await
            .context(error::Io)?;
    }

    Ok(Response::Download)
}

async fn journal(client: Arc<Client>, key: JournalKey) -> ResponseResult {
    let response = client.journal(key).await.context(error::Request)?;
    Ok(Response::Journal(response))
}

async fn view(client: Arc<Client>, key: ViewKey) -> ResponseResult {
    let response = client.view(key).await.context(error::Request)?;
    Ok(Response::View(response))
}

async fn login(client: Arc<Client>, cookies: HeaderValue) -> ResponseResult {
    client.set_cookies(cookies).await.context(error::Client)?;

    Ok(Response::Login)
}

async fn fav(client: Arc<Client>, fav: FavKey) -> ResponseResult {
    let resp = client.fav(fav).await.context(error::Request)?;
    Ok(Response::Fav(resp))
}

async fn unfav(client: Arc<Client>, fav: FavKey) -> ResponseResult {
    let resp = client.unfav(fav).await.context(error::Request)?;
    Ok(Response::Unfav(resp))
}
