package routes

import (
	"cloud.google.com/go/firestore"
	"github.com/fasthttp/router"
	"github.com/valyala/fasthttp"
	"server/internal/handler/space"
)

func SetupSpaceRoutes(r *router.Router, client *firestore.Client) {
	r.POST("/v1/space/join-space", (func(httpCtx *fasthttp.RequestCtx) {
		space.JoinSpaceHandler(httpCtx, client)
	}))
}
