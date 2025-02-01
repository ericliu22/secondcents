package space

import (
	"encoding/json"
	"log"

	"server/internal/core/models"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/valyala/fasthttp"
)

type DeclineSpaceRequest struct {
	SpaceId string `json:"spaceId"`
}

func DeclineSpaceRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}

	var declineRequest DeclineSpaceRequest

	log.Printf("DeclineSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &declineRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, declineRequest.SpaceId)
	if spaceErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get space: %v", spaceErr.Error())
		return
	}

	if space.SpaceRequests == nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Not in spaceRequests")
		return

	}
	var requested bool = false
	for _, member := range *space.SpaceRequests {
		if member == userId {
			requested = true
			break
		}
	}
	if !requested {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Not in spaceRequests")
		return
	}

	firestoreClient.Collection("spaces").Doc(declineRequest.SpaceId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayRemove(userId),
		},
	})
	firestoreClient.Collection("users").Doc(userId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayRemove(declineRequest.SpaceId),
		},
	})
	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Accepted space request successfully")
	//Check if use has incomingSpaceRequest from the specified space
	//Check if space has outgoingSpaceRequest to the specified user
	//Add the user to the space
	//Notify the space that a new member has joined
}
