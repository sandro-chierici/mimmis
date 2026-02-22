package model

// Category represents a classification label that can be attached to costs and fixed costs.
// The ID is a human-readable string key (max 50 chars), not a UUID.
type Category struct {
	ID          string `json:"id"`
	Description string `json:"description"`
}
