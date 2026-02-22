package handler

import (
	"net/http"

	"mimmis/be/internal/model"
	"mimmis/be/internal/repository"

	"github.com/gin-gonic/gin"
)

// CategoryHandler exposes CRUD endpoints for the category resource.
type CategoryHandler struct {
	repo *repository.CategoryRepo
}

func NewCategoryHandler(repo *repository.CategoryRepo) *CategoryHandler {
	return &CategoryHandler{repo: repo}
}

// Register attaches all category routes to the given router group.
// Expected group prefix: /api/v1/categories
func (h *CategoryHandler) Register(rg *gin.RouterGroup) {
	rg.GET("", h.list)
	rg.POST("", h.create)
	rg.GET("/:id", h.get)
	rg.PUT("/:id", h.update)
	rg.DELETE("/:id", h.delete)
}

// list godoc — GET /api/v1/categories
func (h *CategoryHandler) list(c *gin.Context) {
	cats, err := h.repo.GetAll()
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch categories")
		return
	}
	if cats == nil {
		cats = []model.Category{}
	}
	c.JSON(http.StatusOK, cats)
}

// create godoc — POST /api/v1/categories
func (h *CategoryHandler) create(c *gin.Context) {
	var cat model.Category
	if !bindJSON(c, &cat) {
		return
	}
	if err := h.repo.Create(&cat); err != nil {
		writeError(c, http.StatusInternalServerError, "could not create category")
		return
	}
	c.JSON(http.StatusCreated, cat)
}

// get godoc — GET /api/v1/categories/:id
func (h *CategoryHandler) get(c *gin.Context) {
	cat, err := h.repo.GetByID(c.Param("id"))
	if err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "category not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not fetch category")
		return
	}
	c.JSON(http.StatusOK, cat)
}

// update godoc — PUT /api/v1/categories/:id
func (h *CategoryHandler) update(c *gin.Context) {
	var cat model.Category
	if !bindJSON(c, &cat) {
		return
	}
	// The id always comes from the URL, never from the body.
	cat.ID = c.Param("id")

	if err := h.repo.Update(&cat); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "category not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not update category")
		return
	}
	c.JSON(http.StatusOK, cat)
}

// delete godoc — DELETE /api/v1/categories/:id
func (h *CategoryHandler) delete(c *gin.Context) {
	if err := h.repo.Delete(c.Param("id")); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "category not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not delete category")
		return
	}
	c.Status(http.StatusNoContent)
}
