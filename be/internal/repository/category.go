package repository

import (
	"database/sql"
	"mimmis/be/internal/model"
)

// CategoryRepo handles all SQL operations for the category table.
type CategoryRepo struct {
	db *sql.DB
}

func NewCategoryRepo(db *sql.DB) *CategoryRepo {
	return &CategoryRepo{db: db}
}

// Create inserts a new category. The id is supplied by the caller (human-readable string key).
func (r *CategoryRepo) Create(cat *model.Category) error {
	_, err := r.db.Exec(
		`INSERT INTO category (id, description) VALUES ($1, $2)`,
		cat.ID, cat.Description,
	)
	return err
}

// GetAll returns all categories ordered by id.
func (r *CategoryRepo) GetAll() ([]model.Category, error) {
	rows, err := r.db.Query(`SELECT id, description FROM category ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cats []model.Category
	for rows.Next() {
		var cat model.Category
		if err := rows.Scan(&cat.ID, &cat.Description); err != nil {
			return nil, err
		}
		cats = append(cats, cat)
	}
	return cats, rows.Err()
}

// GetByID returns the category with the given id, or sql.ErrNoRows if not found.
func (r *CategoryRepo) GetByID(id string) (*model.Category, error) {
	var cat model.Category
	err := r.db.QueryRow(
		`SELECT id, description FROM category WHERE id = $1`, id,
	).Scan(&cat.ID, &cat.Description)
	if err != nil {
		return nil, err
	}
	return &cat, nil
}

// Update replaces the description of the category.
func (r *CategoryRepo) Update(cat *model.Category) error {
	res, err := r.db.Exec(
		`UPDATE category SET description=$1 WHERE id=$2`,
		cat.Description, cat.ID,
	)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Delete removes the category with the given id.
func (r *CategoryRepo) Delete(id string) error {
	res, err := r.db.Exec(`DELETE FROM category WHERE id=$1`, id)
	if err != nil {
		return err
	}
	if n, _ := res.RowsAffected(); n == 0 {
		return sql.ErrNoRows
	}
	return nil
}
