package model

// FixedCost represents a recurring fixed cost linked to a user.
type FixedCost struct {
	ID         int32  `json:"id"`
	UserID     string `json:"userId"`
	CategoryID string `json:"categoryId"`
	ApplyDay   int    `json:"applyDay"`
	Cost       int64  `json:"cost"`
	Enabled    bool   `json:"enabled"`
	Note       string `json:"note"`
	ShadowCost bool   `json:"shadowCost"`
}
