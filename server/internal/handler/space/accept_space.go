package space

import (
	"encoding/json"
	"log"

	"server/internal/core/models"
	"server/internal/core/notifications"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/valyala/fasthttp"
)

type AcceptSpaceRequest struct {
	SpaceId string `json:"spaceId"`
}

func AcceptSpaceRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}

	var acceptRequest AcceptSpaceRequest

	log.Printf("JoinSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &acceptRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, acceptRequest.SpaceId)
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

	firestoreClient.Collection("spaces").Doc(acceptRequest.SpaceId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "members",
			Value: firestore.ArrayUnion(userId),
		},
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayRemove(userId),
		},
	})
	firestoreClient.Collection("users").Doc(userId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayRemove(acceptRequest.SpaceId),
		},
	})
	user, userErr := models.GetUser(firestoreClient, firebaseCtx, userId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get private user: %v", userErr.Error())
		return
	}

	var notification notifications.TopicNotification
	notification = notifications.TopicNotification{
		Topic: space.Name,
		Title: user.Name + " just joined the Space!",
		Body:  "",
	}
	if err := notifications.SendTopicNotification(&notification, messagingClient, firebaseCtx); err != nil {
		log.Printf("Failed to send notification: %v", err.Error())
	}

	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Accepted space request successfully")
	//Check if use has incomingSpaceRequest from the specified space
	//Check if space has outgoingSpaceRequest to the specified user
	//Add the user to the space
	//Notify the space that a new member has joined
}
