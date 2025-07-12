use lazybe::macros::{Entity, Enum, Newtype};
use serde::{Deserialize, Serialize};
use sqlx::types::chrono::{DateTime, Utc};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Newtype)]
pub struct TodoId(u64);

#[derive(Debug, Clone, Serialize, Deserialize, Entity)]
#[lazybe(table = "todo")]
pub struct Todo {
    #[lazybe(primary_key)]
    pub id: TodoId,
    pub title: String,
    pub description: Option<String>,
    pub status: TodoStatus,
    #[lazybe(created_at)]
    pub created_at: DateTime<Utc>,
    #[lazybe(updated_at)]
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Enum)]
pub enum TodoStatus {
    Todo,
    Doing,
    Done,
}
