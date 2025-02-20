package space

import (
	"encoding/json"
	"log"

	"server/internal/core/auth"
	"server/internal/core/models"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
)

type DeleteSpaceRequest struct {
	SpaceId string `json:"spaceId"`
}

func DeleteSpaceRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}
	var deleteRequest DeleteSpaceRequest

	log.Printf("DeleteSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &deleteRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, deleteRequest.SpaceId)
	if spaceErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get space: %v", spaceErr.Error())
		return
	}

	if !auth.IsMember(space, userId) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("User not a part of space")
		return
	}

	if space.SpaceRequests == nil {
		httpCtx.SetStatusCode(fasthttp.StatusOK)
		httpCtx.SetBodyString("Deleted Space successfully")
	}
	for _, requestId := range *space.SpaceRequests {
		_, updateErr := firestoreClient.Collection("users").Doc(requestId).Update(firebaseCtx, []firestore.Update{
			{
				Path:  "spaceRequests",
				Value: firestore.ArrayRemove(deleteRequest.SpaceId),
			},
		})
		if updateErr != nil {
			httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
			log.Printf("Failed to update user space requests: %v", updateErr.Error())
			return
		}
	}

	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Deleted Space successfully")
}
