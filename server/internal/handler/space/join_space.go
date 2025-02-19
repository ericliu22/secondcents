package space

import (
	"encoding/json"
	"log"

	"server/internal/core/auth"
	"server/internal/core/models"
	"server/internal/core/notifications"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
	"github.com/valyala/fasthttp"
)

type JoinSpaceRequest struct {
	SpaceId    string `json:"spaceId"`
	SpaceToken string `json:"spaceToken"`
}

func JoinSpaceHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
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

	log.Printf("Parsed join request: %+v\n", joinRequest)
	validSpace, spaceErr := auth.ValidateSpaceToken(firebaseCtx, firestoreClient, joinRequest.SpaceToken, joinRequest.SpaceId)
	if spaceErr != nil {
		log.Printf("Interal Server Error")
		httpCtx.Error("Internal Server Error", fasthttp.StatusInternalServerError)
		return
	}

	if !validSpace {
		log.Printf("Invalid spaceToken")
		httpCtx.Error("spaceToken is not valid JWT token", fasthttp.StatusUnauthorized)
		return
	}

	firestoreClient.Collection("spaces").Doc(joinRequest.SpaceId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "members",
			Value: firestore.ArrayUnion(userId),
		},
	})

	user, userErr := models.GetUser(firestoreClient, firebaseCtx, userId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get private user: %v", userErr.Error())
		return
	}

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, joinRequest.SpaceId)
	if spaceErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get space: %v", spaceErr.Error())
		return
	}

	var notification notifications.TopicNotification
	notification = notifications.TopicNotification{
		Topic: joinRequest.SpaceId,
		Title: space.Name,
		Body:  user.Name + " just joined the Space!",
	}
	if err := notifications.SendTopicNotification(&notification, messagingClient, firebaseCtx); err != nil {
		log.Printf("Failed to send notification: %v", err.Error())
	}

	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Joined Space successfully")
}
