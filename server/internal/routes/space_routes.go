package routes

import (
	"server/internal/handler/space"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/fasthttp/router"
	"github.com/valyala/fasthttp"
)

func SetupSpaceRoutes(r *router.Router, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	r.POST("/v1/space/join-space", (func(httpCtx *fasthttp.RequestCtx) {
		space.JoinSpaceHandler(httpCtx, firestoreClient)
	}))
	r.POST("/v1/space/fetch-space-token", (func(httpCtx *fasthttp.RequestCtx) {
		space.FetchSpaceTokenHandler(httpCtx, firestoreClient)
	}))

	r.POST("/v1/space/space-notification", (func(httpCtx *fasthttp.RequestCtx) {
		space.SpaceNotificationHandler(httpCtx, firestoreClient, messagingClient)
	}))
}
