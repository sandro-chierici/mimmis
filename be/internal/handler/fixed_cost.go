package handler

import (
	"net/http"

	"mimmis/be/internal/model"
	"mimmis/be/internal/repository"

	"github.com/gin-gonic/gin"
)

// FixedCostHandler exposes CRUD endpoints for the fixed_costs resource.
type FixedCostHandler struct {
	repo *repository.FixedCostRepo
}

func NewFixedCostHandler(repo *repository.FixedCostRepo) *FixedCostHandler {
	return &FixedCostHandler{repo: repo}
}

// Register attaches all fixed-cost routes to the given router group.
// Expected group prefix: /api/v1/fixed
func (h *FixedCostHandler) Register(rg *gin.RouterGroup) {
	rg.GET("", h.list)
	rg.POST("", h.create)
	rg.GET("/:id", h.get)
	rg.PUT("/:id", h.update)
	rg.DELETE("/:id", h.delete)
}

// list godoc — GET /api/v1/fixed
func (h *FixedCostHandler) list(c *gin.Context) {
	items, err := h.repo.GetAll()
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch fixed costs")
		return
	}
	if items == nil {
		items = []model.FixedCost{}
	}
	c.JSON(http.StatusOK, items)
}

// create godoc — POST /api/v1/fixed
func (h *FixedCostHandler) create(c *gin.Context) {
	var fc model.FixedCost
	if !bindJSON(c, &fc) {
		return
	}
	if err := h.repo.Create(&fc); err != nil {
		writeError(c, http.StatusInternalServerError, "could not create fixed cost")
		return
	}
	c.JSON(http.StatusCreated, fc)
}

// get godoc — GET /api/v1/fixed/:id
func (h *FixedCostHandler) get(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	fc, err := h.repo.GetByID(id)
	if err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "fixed cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not fetch fixed cost")
		return
	}
	c.JSON(http.StatusOK, fc)
}

// update godoc — PUT /api/v1/fixed/:id
func (h *FixedCostHandler) update(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	var fc model.FixedCost
	if !bindJSON(c, &fc) {
		return
	}
	fc.ID = id

	if err := h.repo.Update(&fc); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "fixed cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not update fixed cost")
		return
	}
	c.JSON(http.StatusOK, fc)
}

// delete godoc — DELETE /api/v1/fixed/:id
func (h *FixedCostHandler) delete(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	if err := h.repo.Delete(id); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "fixed cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not delete fixed cost")
		return
	}
	c.Status(http.StatusNoContent)
}
