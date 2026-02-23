package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	appdb "mimmis/be/internal/db"
	"mimmis/be/internal/handler"
	"mimmis/be/internal/repository"
	"mimmis/be/internal/router"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "6000"
	}

	// ── Database ──────────────────────────────────────────────────────────────
	db, err := appdb.Connect()
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Apply schema migrations on startup (idempotent).
	if err := appdb.Migrate(db); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}
	log.Println("Database migrations applied")

	// ── Dependency wiring ─────────────────────────────────────────────────────
	// Repositories wrap raw SQL; handlers depend only on their own repository.
	userHandler := handler.NewUserHandler(repository.NewUserRepo(db))
	costHandler := handler.NewCostHandler(repository.NewCostRepo(db))
	fixedHandler := handler.NewFixedCostHandler(repository.NewFixedCostRepo(db))
	categoryHandler := handler.NewCategoryHandler(repository.NewCategoryRepo(db))

	r := router.New(userHandler, costHandler, fixedHandler, categoryHandler)

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine so it doesn't block graceful shutdown
	go func() {
		log.Printf("Server listening on port %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited gracefully")
}
