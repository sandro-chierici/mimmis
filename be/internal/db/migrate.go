package db

import "database/sql"

// schema contains all DDL statements that create the database tables.
// Each statement is idempotent (IF NOT EXISTS), so it is safe to run on every startup.
const schema = `
CREATE TABLE IF NOT EXISTS users (
    user_id TEXT PRIMARY KEY,
    name    TEXT NOT NULL,
    surname TEXT NOT NULL,
    mail    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS category (
    id          VARCHAR(50) PRIMARY KEY,
    description TEXT        NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS costs (
    id          SERIAL      PRIMARY KEY,
    user_id     TEXT        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id VARCHAR(50) REFERENCES category(id) ON DELETE SET NULL,
    date        TIMESTAMPTZ NOT NULL,
    total       BIGINT      NOT NULL,
    note        TEXT        NOT NULL DEFAULT '',
    name        TEXT        NOT NULL,
    ref_month   INT         NOT NULL,
    ref_year    INT         NOT NULL,
    shadow_cost BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS fixed_costs (
    id          SERIAL      PRIMARY KEY,
    user_id     TEXT        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id VARCHAR(50) REFERENCES category(id) ON DELETE SET NULL,
    apply_day   INT         NOT NULL,
    expense     BIGINT      NOT NULL,
    enabled     BOOLEAN     NOT NULL DEFAULT TRUE,
    note        TEXT        NOT NULL DEFAULT '',
    shadow_cost BOOLEAN     NOT NULL DEFAULT FALSE
);
`

// Migrate applies the schema to the database.
// It is idempotent and safe to call on every application start.
func Migrate(db *sql.DB) error {
	_, err := db.Exec(schema)
	return err
}
