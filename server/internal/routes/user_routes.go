package routes

import (
	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"github.com/fasthttp/router"
	"server/internal/handler/user"
)

func SetupUserRoutes(client *firestore.Client) *router.Router {
	r := router.New()

	r.POST("/accept-friend-request/", (func(httpCtx *fasthttp.RequestCtx) {
		user.AcceptFriendRequestHandler(httpCtx, client)
	}))
	r.POST("/send-friend-request/", (func(httpCtx *fasthttp.RequestCtx) {
		user.SendFriendRequestHandler(httpCtx, client)
	}))

	return r
}
