// Package repository contains database access logic for each entity.
package repository

import (
	"database/sql"
	"fmt"
	"mimmis/be/internal/model"
	"mimmis/be/internal/uid"
)

// UserRepo handles all SQL operations for the users table.
type UserRepo struct {
	db *sql.DB
}

func NewUserRepo(db *sql.DB) *UserRepo {
	return &UserRepo{db: db}
}

// Create inserts a new user, assigning a fresh UUIDv7 as the primary key.
func (r *UserRepo) Create(u *model.User) error {
	id, err := uid.NewV7()
	if err != nil {
		return fmt.Errorf("userRepo.Create: generate id: %w", err)
	}
	u.UserID = id

	_, err = r.db.Exec(
		`INSERT INTO users (user_id, name, surname, mail) VALUES ($1, $2, $3, $4)`,
		u.UserID, u.Name, u.Surname, u.Mail,
	)
	return err
}

// GetAll returns every user ordered by surname, name.
func (r *UserRepo) GetAll() ([]model.User, error) {
	rows, err := r.db.Query(
		`SELECT user_id, name, surname, mail FROM users ORDER BY surname, name`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []model.User
	for rows.Next() {
		var u model.User
		if err := rows.Scan(&u.UserID, &u.Name, &u.Surname, &u.Mail); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

// GetByID returns the user with the given id, or sql.ErrNoRows if not found.
func (r *UserRepo) GetByID(id string) (*model.User, error) {
	var u model.User
	err := r.db.QueryRow(
		`SELECT user_id, name, surname, mail FROM users WHERE user_id = $1`, id,
	).Scan(&u.UserID, &u.Name, &u.Surname, &u.Mail)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

// Update overwrites name, surname, and mail for the given user.
func (r *UserRepo) Update(u *model.User) error {
	res, err := r.db.Exec(
		`UPDATE users SET name=$1, surname=$2, mail=$3 WHERE user_id=$4`,
		u.Name, u.Surname, u.Mail, u.UserID,
	)
	if err != nil {
		return err
	}
	// Return ErrNoRows so the handler can distinguish 404 vs 500.
	if n, _ := res.RowsAffected(); n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Delete removes the user (and cascades to costs/fixed_costs via ON DELETE CASCADE).
func (r *UserRepo) Delete(id string) error {
	res, err := r.db.Exec(`DELETE FROM users WHERE user_id=$1`, id)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return sql.ErrNoRows
	}
	return nil
}
