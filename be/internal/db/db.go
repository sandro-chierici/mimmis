// Package db handles database connection and schema migrations.
package db

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq" // Register the postgres driver for database/sql.
)

// Connect opens and validates a Postgres connection using environment variables.
// Reads: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, DB_SSLMODE.
func Connect() (*sql.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		getenv("DB_HOST", "localhost"),
		getenv("DB_PORT", "5432"),
		getenv("DB_USER", "postgres"),
		getenv("DB_PASSWORD", ""),
		getenv("DB_NAME", "mimmis"),
		getenv("DB_SSLMODE", "disable"),
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("db: open: %w", err)
	}

	// Verify the connection is alive before returning.
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("db: ping: %w", err)
	}

	return db, nil
}

// getenv returns the environment variable value or a fallback default.
func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
