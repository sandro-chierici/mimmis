package model

// Cost represents a spending entry linked to a user.
type Cost struct {
	ID         int32  `json:"id"`
	UserID     string `json:"userId"`
	CategoryID string `json:"categoryId"`
	Total      int64  `json:"total"`
	Note       string `json:"note"`
	Name       string `json:"name"`
	RefDay     int    `json:"refDay"`
	RefMonth   int    `json:"refMonth"`
	RefYear    int    `json:"refYear"`
	ShadowCost bool   `json:"shadowCost"`
}
