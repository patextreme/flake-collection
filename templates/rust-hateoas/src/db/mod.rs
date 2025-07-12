use lazybe::db::DbOps;
use lazybe::db::sqlite::SqliteDbCtx;
use lazybe::filter::Filter;
use lazybe::sort::Sort;
use sqlx::SqlitePool;

mod entities;

#[derive(Debug, Clone)]
pub struct SqliteDb {
    pool: SqlitePool,
    db_ctx: SqliteDbCtx,
}

impl SqliteDb {
    pub async fn connect(db_url: &str) -> anyhow::Result<Self> {
        let pool = SqlitePool::connect(db_url).await?;
        Ok(Self {
            db_ctx: SqliteDbCtx,
            pool,
        })
    }

    pub async fn migrate(&self) -> anyhow::Result<()> {
        sqlx::migrate!("./migrations").run(&self.pool).await?;
        Ok(())
    }

    pub async fn get_todos(&self) -> anyhow::Result<Vec<entities::Todo>> {
        let mut tx = self.pool.begin().await?;
        let todos = self
            .db_ctx
            .list::<entities::Todo>(
                &mut tx,
                Filter::empty(),
                Sort::new([entities::TodoSort::id().asc()]),
                None,
            )
            .await?;
        Ok(todos.data)
    }
}
