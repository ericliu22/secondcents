package routes

import (
	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"github.com/fasthttp/router"
	"server/internal/handler/user"
)

func SetupUserRoutes(client *firestore.Client) *router.Router {
	r := router.New()

	// Use the middleware to attach context
	r.GET("/{id}/friend-request/", (func(httpCtx *fasthttp.RequestCtx) {
		user.AcceptFriendRequestHandler(httpCtx, client)
	}))

	return r
}
