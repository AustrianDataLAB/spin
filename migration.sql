CREATE TABLE IF NOT EXISTS todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  description TEXT NOT NULL,
  due_date DATE,
  starred BOOLEAN DEFAULT 0,
  is_completed BOOLEAN DEFAULT 0
);