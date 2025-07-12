use axum::Router;
use axum::extract::State;
use axum::routing::get;
use clap::Parser;
use cli::CliArgs;
use maud::{Markup, html};
use tower_http::trace::TraceLayer;

use crate::db::SqliteDb;

mod cli;
mod db;

#[derive(Clone)]
struct AppState {
    db: SqliteDb,
}

pub async fn start_server() -> anyhow::Result<()> {
    let cli = CliArgs::parse();

    let db = SqliteDb::connect(&cli.db_url)
        .await
        .expect("Unable to connect to database");

    // init migrations
    if cli.skip_migration {
        tracing::info!("Skipping database migrations");
    } else {
        tracing::info!("Applying database migrations");
        db.migrate().await.expect("Failed to apply migrations");
        tracing::info!("Applied database migrations successfully");
    }

    // init state
    let state = AppState { db };

    // start server
    let router = Router::new()
        .route("/", get(home_page))
        .with_state(state)
        .layer(TraceLayer::new_for_http());
    let bind_addr = format!("{}:{}", cli.address, cli.port);
    let listener = tokio::net::TcpListener::bind(&bind_addr).await?;
    tracing::info!("Server is listening on {}", bind_addr);
    axum::serve(listener, router).await?;

    Ok(())
}

async fn home_page(State(state): State<AppState>) -> Markup {
    let todos = state.db.get_todos().await.expect("Failed to get data from database");

    html! {
        p { "My todo list" }
        p {
            ol {
                @for todo in todos {
                    li { (todo.title) }
                }
            }
        }
    }
}
