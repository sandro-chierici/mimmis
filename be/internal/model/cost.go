package model

import "time"

// Cost represents a spending entry linked to a user.
type Cost struct {
	ID         int32     `json:"id"`
	UserID     string    `json:"userId"`
	CategoryID string    `json:"categoryId"`
	Date       time.Time `json:"date"`
	Total      int64     `json:"total"`
	Note       string    `json:"note"`
	Name       string    `json:"name"`
	RefMonth   int       `json:"refMonth"`
	RefYear    int       `json:"refYear"`
}
