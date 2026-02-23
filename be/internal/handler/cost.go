package handler

import (
	"net/http"

	"mimmis/be/internal/model"
	"mimmis/be/internal/repository"

	"github.com/gin-gonic/gin"
)

// CostHandler exposes CRUD endpoints for the costs resource.
type CostHandler struct {
	repo *repository.CostRepo
}

func NewCostHandler(repo *repository.CostRepo) *CostHandler {
	return &CostHandler{repo: repo}
}

// Register attaches all cost routes to the given router group.
// Expected group prefix: /api/v1/costs
func (h *CostHandler) Register(rg *gin.RouterGroup) {
	rg.GET("/year/:ref_year/month/:ref_month", h.list)
	rg.GET("/user/:user_id/year/:ref_year/month/:ref_month", h.listPerUser)
	rg.POST("", h.create)
	rg.GET("/:id", h.get)
	rg.GET("/total/user/:user_id/year/:ref_year/month/:ref_month", h.getTotalCostsPerUser)
	rg.GET("/total/year/:ref_year/month/:ref_month", h.getTotalCostsPerPeriod)
	rg.PUT("/:id", h.update)
	rg.DELETE("/:id", h.delete)
}

// list godoc — GET /api/v1/costs/year/:ref_year/month/:ref_month
func (h *CostHandler) list(c *gin.Context) {
	refYear, ok := parseIntID(c, "ref_year")
	if !ok {
		return
	}
	refMonth, ok := parseIntID(c, "ref_month")
	if !ok {
		return
	}
	costs, err := h.repo.GetAll(refYear, refMonth)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch costs")
		return
	}
	if costs == nil {
		costs = []model.Cost{}
	}
	c.JSON(http.StatusOK, costs)
}

// listPerUser godoc — GET /api/v1/costs/user/:user_id/year/:ref_year/month/:ref_month
func (h *CostHandler) listPerUser(c *gin.Context) {
	userID := c.Param("user_id")
	refYear, ok := parseIntID(c, "ref_year")
	if !ok {
		return
	}
	refMonth, ok := parseIntID(c, "ref_month")
	if !ok {
		return
	}
	costs, err := h.repo.GetCostsPerUser(repository.CostAggregateRequest{
		UserID:   userID,
		RefYear:  refYear,
		RefMonth: refMonth,
	})
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch costs")
		return
	}
	if costs == nil {
		costs = []model.Cost{}
	}
	c.JSON(http.StatusOK, costs)
}

// create godoc — POST /api/v1/costs
func (h *CostHandler) create(c *gin.Context) {
	var cost model.Cost
	if !bindJSON(c, &cost) {
		return
	}
	if err := h.repo.Create(&cost); err != nil {
		writeError(c, http.StatusInternalServerError, "could not create cost")
		return
	}
	c.JSON(http.StatusCreated, cost)
}

// get godoc — GET /api/v1/costs/:id
func (h *CostHandler) get(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	cost, err := h.repo.GetByID(id)
	if err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not fetch cost")
		return
	}
	c.JSON(http.StatusOK, cost)
}

// update godoc — PUT /api/v1/costs/:id
func (h *CostHandler) update(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	var cost model.Cost
	if !bindJSON(c, &cost) {
		return
	}
	// The id always comes from the URL, never from the body.
	cost.ID = id

	if err := h.repo.Update(&cost); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not update cost")
		return
	}
	c.JSON(http.StatusOK, cost)
}

// delete godoc — DELETE /api/v1/costs/:id
func (h *CostHandler) delete(c *gin.Context) {
	id, ok := parseIntID(c, "id")
	if !ok {
		return
	}
	if err := h.repo.Delete(id); err != nil {
		if isNotFound(err) {
			writeError(c, http.StatusNotFound, "cost not found")
			return
		}
		writeError(c, http.StatusInternalServerError, "could not delete cost")
		return
	}
	c.Status(http.StatusNoContent)
}

// getTotalCostsPerUser godoc — GET /api/v1/costs/total/user/:user_id/year/:ref_year/month/:ref_month
func (h *CostHandler) getTotalCostsPerUser(c *gin.Context) {
	userID := c.Param("user_id")
	refYear, ok := parseIntID(c, "ref_year")
	if !ok {
		return
	}
	refMonth, ok := parseIntID(c, "ref_month")
	if !ok {
		return
	}

	total, err := h.repo.GetTotalPerUser(repository.CostAggregateRequest{
		UserID:   userID,
		RefYear:  refYear,
		RefMonth: refMonth,
	})
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch total costs")
		return
	}
	c.JSON(http.StatusOK, gin.H{"total": total})
}

// getTotalCostsPerPeriod godoc — GET /api/v1/costs/total/year/:ref_year/month/:ref_month
func (h *CostHandler) getTotalCostsPerPeriod(c *gin.Context) {
	refYear, ok := parseIntID(c, "ref_year")
	if !ok {
		return
	}
	refMonth, ok := parseIntID(c, "ref_month")
	if !ok {
		return
	}

	total, err := h.repo.GetTotalPerPeriod(refYear, refMonth)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "could not fetch total costs")
		return
	}
	c.JSON(http.StatusOK, gin.H{"total": total})
}
