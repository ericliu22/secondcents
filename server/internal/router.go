package internal

import (
	"server/internal/handler"

	"firebase.google.com/go"
	"github.com/valyala/fasthttp"
	"github.com/fasthttp/router"
)

// SetupRouter initializes and returns the router
func SetupRouter(app *firebase.App) *router.Router {
    r := router.New()

    r.GET("/", handler.HomeHandler)
    r.GET("/v1", handler.V1Handler)
    r.POST("/v1/notification", func(ctx *fasthttp.RequestCtx) {
        handler.NotificationHandler(ctx, app)
    })

    //r.POST("/api/data", handler.DataHandler)

    return r
}

