package space

import (
	"log"
	"encoding/json" 

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
	"server/internal/core/auth"
)

type JoinSpaceRequest struct {
	SpaceId string `json:"spaceId"`
	SpaceToken string `json:"spaceToken"`
}

func JoinSpaceHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}
	var joinRequest JoinSpaceRequest

	log.Printf("JoinSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &joinRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", joinRequest)
	validSpace, spaceErr := auth.ValidateSpaceToken(firebaseCtx, client, joinRequest.SpaceToken, joinRequest.SpaceId)
	if (spaceErr != nil) {
		log.Printf("Interal Server Error")
		httpCtx.Error("Internal Server Error", fasthttp.StatusInternalServerError)
		return
	}

	if (!validSpace) {
		log.Printf("Invalid spaceToken")
		httpCtx.Error("spaceToken is not valid JWT token", fasthttp.StatusUnauthorized)
		return
	}

	client.Collection("spaces").Doc(joinRequest.SpaceId).Update(firebaseCtx, []firestore.Update{
		{
			Path: "members",
			Value: firestore.ArrayUnion(userId),
		},
	})
}
