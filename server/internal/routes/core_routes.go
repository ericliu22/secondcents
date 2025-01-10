package routes

import (
	"server/internal/handler"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go"
	"github.com/fasthttp/router"
	"github.com/valyala/fasthttp"
)

// SetupCoreRouter initializes and returns the router
func SetupCoreRouter(app *firebase.App, client *firestore.Client) *router.Router {
	r := router.New()

	r.GET("/", handler.HomeHandler)
	r.GET("/v1", handler.VersionOneHandler)
	r.POST("/v1/notification", func(ctx *fasthttp.RequestCtx) {
		handler.NotificationHandler(ctx, app)
	})

	SetupUserRoutes(r, client)
	SetupSpaceRoutes(r, client)

	return r
}
