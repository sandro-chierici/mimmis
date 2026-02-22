package handler

import (
	"net/http"

	"mimmis/be/internal/model"
	"mimmis/be/internal/repository"

	"github.com/gin-gonic/gin"
)

// UserHandler exposes CRUD endpoints for the users resource.
type UserHandler struct {
	repo *repository.UserRepo
}

func NewUserHandler(repo *repository.UserRepo) *UserHandler {
	return &UserHandler{repo: repo}
}

// Register attaches all user routes to the given router group.
// Expected group prefix: /api/v1/users
func (h *UserHandler) Register(rg *gin.RouterGroup) {
	rg.GET("", h.list)
	rg.POST("", h.create)
	rg.GET("/:id", h.get)
	rg.PUT("/:id", h.update)
	rg.DELETE("/:id", h.delete)
}

// list godoc — GET /api/v1/users
func (h *UserHandler) list(c *gin.Context) {
	users, err := h.repo.GetAll()
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch users")
		return
	}
	// Return an empty array instead of null when there are no users.
	if users == nil {
		users = []model.User{}
	}
	c.JSON(http.StatusOK, users)
}

// create godoc — POST /api/v1/users
func (h *UserHandler) create(c *gin.Context) {
	var u model.User
	if !bindJSON(c, &u) {
		return
	}
	if err := h.repo.Create(&u); err != nil {
		writeError(c, http.StatusInternalServerError, "could not create user")
		return
	}
	c.JSON(http.StatusCreated, u)
}

// get godoc — GET /api/v1/users/:id
func (h *UserHandler) get(c *gin.Context) {
	u, err := h.repo.GetByID(c.Param("id"))
	if err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "user not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not fetch user")
		return
	}
	c.JSON(http.StatusOK, u)
}

// update godoc — PUT /api/v1/users/:id
func (h *UserHandler) update(c *gin.Context) {
	var u model.User
	if !bindJSON(c, &u) {
		return
	}
	// The id always comes from the URL, never from the body.
	u.UserID = c.Param("id")

	if err := h.repo.Update(&u); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "user not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not update user")
		return
	}
	c.JSON(http.StatusOK, u)
}

// delete godoc — DELETE /api/v1/users/:id
func (h *UserHandler) delete(c *gin.Context) {
	if err := h.repo.Delete(c.Param("id")); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "user not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not delete user")
		return
	}
	c.Status(http.StatusNoContent)
}
