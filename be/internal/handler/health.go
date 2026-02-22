package handler

import (
	"net/http"
	"time"

	"mimmis/be/internal/model"

	"github.com/gin-gonic/gin"
)

// Health godoc
// @Summary     Health check
// @Description Returns the current health status of the service
// @Tags        health
// @Produce     json
// @Success     200 {object} model.HealthResponse
// @Router      /health [get]
func Health(c *gin.Context) {
	c.JSON(http.StatusOK, model.HealthResponse{
		Status:    "ok",
		Timestamp: time.Now().UTC(),
	})
}
