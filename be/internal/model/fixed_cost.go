package model

// FixedCost represents a recurring fixed expense linked to a user.
type FixedCost struct {
	ID         int32  `json:"id"`
	UserID     string `json:"userId"`
	CategoryID string `json:"categoryId"`
	ApplyDay   int    `json:"applyDay"`
	Expense    int64  `json:"expense"`
	Enabled    bool   `json:"enabled"`
	Note       string `json:"note"`
	ShadowCost bool   `json:"shadowCost"`
}
