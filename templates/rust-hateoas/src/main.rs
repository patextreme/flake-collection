use half_baked::start_server;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    start_server().await?;
    Ok(())
}
