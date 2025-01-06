package space

import (
	"log"
	"encoding/json" 

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
)

type JoinSpaceRequest struct {
	SpaceToken string `json:"spaceToken"`
}

func JoinSpaceHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var joinRequest JoinSpaceRequest

	log.Printf("JoinSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &joinRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", joinRequest)

	if (!isAuthenticated(httpCtx, joinRequest.SpaceToken)) {
		log.Printf("Unauthenticated request")
		return
	}
}
