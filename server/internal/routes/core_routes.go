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

	userRouter := SetupUserRoutes(client)

	r.ANY("/v1/user/{wildcard:*}", func(ctx *fasthttp.RequestCtx) {
		// Strip the "/user" prefix and forward to the user router
		ctx.SetUserValue("wildcard", ctx.Path()[len("/user"):])
		userRouter.Handler(ctx)
	})

	return r
}
