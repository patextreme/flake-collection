use std::net::Ipv4Addr;

use clap::Parser;

#[derive(Parser)]
pub struct CliArgs {
    /// Database URL (e.g. sqlite://data.db)
    #[arg(long, env = "DB_URL", default_value = "sqlite::memory:")]
    pub db_url: String,
    /// Skip database migration on Node startup
    #[arg(long, env = "SKIP_MIGRATION")]
    pub skip_migration: bool,
    /// HTTP server binding address
    #[arg(long, env = "HTTP_ADDRESS", default_value = "0.0.0.0")]
    pub address: Ipv4Addr,
    /// HTTP server listening port
    #[arg(long, short, env = "HTTP_PORT", default_value_t = 8080)]
    pub port: u16,
}
