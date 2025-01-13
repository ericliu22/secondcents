package routes

import (
	"server/internal/handler"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/fasthttp/router"
)

// SetupCoreRouter initializes and returns the router
func SetupCoreRouter(firestoreClient *firestore.Client, messagingClient *messaging.Client) *router.Router {
	r := router.New()

	r.GET("/", handler.HomeHandler)
	r.GET("/v1", handler.VersionOneHandler)

	SetupUserRoutes(r, firestoreClient, messagingClient)
	SetupSpaceRoutes(r, firestoreClient, messagingClient)

	return r
}
