package model

// User represents a registered user.
type User struct {
	UserID  string `json:"userId"`
	Name    string `json:"name"`
	Surname string `json:"surname"`
	Mail    string `json:"mail"`
}
