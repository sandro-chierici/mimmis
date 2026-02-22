package model

import "time"

// HealthResponse represents the response payload for the /health endpoint.
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
}

// ErrorResponse represents a generic error response payload.
type ErrorResponse struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}
