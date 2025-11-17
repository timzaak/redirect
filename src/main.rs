use salvo::prelude::*;
use tracing_subscriber::EnvFilter;

#[handler]
async fn redirect_to_https(req: &mut Request, res: &mut Response) {
    let host = req.header::<String>("host").unwrap_or_default();
    let path_and_query = req.uri().path_and_query().map(|pq| pq.as_str()).unwrap_or("/");
    let redirect_url = format!("https://{}{}", host, path_and_query);
    res.render(Redirect::found(redirect_url));
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let router = Router::new().path("{**rest}").goal(redirect_to_https);
    let acceptor = TcpListener::new("0.0.0.0:8080").bind().await;
    println!("start....");
    Server::new(acceptor).serve(router).await;

    Ok(())
}
