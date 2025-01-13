package routes

import (
	"server/internal/handler/user"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/fasthttp/router"
	"github.com/valyala/fasthttp"
)

func SetupUserRoutes(r *router.Router, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	r.POST("/v1/user/accept-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.AcceptFriendRequestHandler(httpCtx, firestoreClient, messagingClient)
	}))
	r.POST("/v1/user/send-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.SendFriendRequestHandler(httpCtx, firestoreClient, messagingClient)
	}))
	r.POST("/v1/user/unsend-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.UnsendFriendRequestHandler(httpCtx, firestoreClient)
	}))
	r.POST("/v1/user/remove-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.RemoveFriendRequestHandler(httpCtx, firestoreClient)
	}))
	r.POST("/v1/user/decline-friend-request", (func(httpCtx *fasthttp.RequestCtx) {
		user.DeclineFriendRequestHandler(httpCtx, firestoreClient)
	}))

	r.POST("/v1/user/user-notification", (func(httpCtx *fasthttp.RequestCtx) {
		user.UserNotificationHandler(httpCtx, firestoreClient, messagingClient)
	}))
}
