package router

import (
	"mimmis/be/internal/handler"
	"mimmis/be/internal/middleware"

	"github.com/gin-gonic/gin"
)

// New creates and configures the main Gin router.
// Each resource handler is injected here so the router stays decoupled from the DB.
func New(
	users *handler.UserHandler,
	costs *handler.CostHandler,
	fixed *handler.FixedCostHandler,
	categories *handler.CategoryHandler,
) *gin.Engine {
	r := gin.New()

	// Global middleware
	r.Use(gin.Recovery())
	r.Use(middleware.Logger())
	r.Use(middleware.CORS())

	// Health check — intentionally outside the versioned group
	r.GET("/health", handler.Health)

	// Versioned API group
	v1 := r.Group("/api/v1")
	{
		users.Register(v1.Group("/users"))
		costs.Register(v1.Group("/costs"))
		fixed.Register(v1.Group("/fixed"))
		categories.Register(v1.Group("/categories"))
	}

	return r
}
