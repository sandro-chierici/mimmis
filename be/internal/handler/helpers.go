package handler

import (
	"database/sql"
	"net/http"
	"strconv"

	"mimmis/be/internal/model"

	"github.com/gin-gonic/gin"
)

// writeError sends a JSON error response with the given HTTP status and message.
// Using this helper ensures a consistent error shape across all endpoints.
func writeError(c *gin.Context, status int, message string) {
	c.JSON(status, model.ErrorResponse{Code: status, Message: message})
}

// isNotFound returns true when the repository signals that a row was not found.
func isNotFound(err error) bool {
	return err == sql.ErrNoRows
}

// bindJSON tries to decode the request body into dst and replies 400 on failure.
// Returns false when decoding failed (the response has already been written).
func bindJSON(c *gin.Context, dst any) bool {
	if err := c.ShouldBindJSON(dst); err != nil {
		writeError(c, http.StatusBadRequest, "invalid request body: "+err.Error())
		return false
	}
	return true
}

// parseIntID parses the named URL parameter as an int32.
// On failure it writes a 400 response and returns false.
func parseIntID(c *gin.Context, param string) (int32, bool) {
	raw := c.Param(param)
	v, err := strconv.ParseInt(raw, 10, 32)
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid id: must be an integer")
		return 0, false
	}
	return int32(v), true
}
