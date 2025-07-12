-- Add migration script here
CREATE TABLE todo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

INSERT INTO todo (title, status, created_at, updated_at) VALUES
('Do homework#1', 'Todo', '2025-01-01 14:30:00', '2025-01-01 14:30:00'),
('Do homework#2', 'Doing', '2025-01-01 14:30:00', '2025-01-01 14:30:00'),
('Do homework#3', 'Done', '2025-01-01 14:30:00', '2025-01-01 14:30:00');
