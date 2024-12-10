package routes

import (
	"cloud.google.com/go/firestore"
	"github.com/fasthttp/router"
	"github.com/valyala/fasthttp"
	"server/internal/handler/user"
)

func SetupUserRoutes(r *router.Router, client *firestore.Client) {
	r.POST("/v1/user/accept-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.AcceptFriendRequestHandler(httpCtx, client)
	}))
	r.POST("/v1/user/send-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.SendFriendRequestHandler(httpCtx, client)
	}))
	r.POST("/v1/user/unsend-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.UnsendFriendRequestHandler(httpCtx, client)
	}))
	r.POST("/v1/user/remove-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.RemoveFriendRequestHandler(httpCtx, client)
	}))
	r.POST("/v1/user/decline-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.DeclineFriendRequestHandler(httpCtx, client)
	}))
}
