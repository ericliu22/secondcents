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

type InviteSpaceRequest struct {
	SpaceId string `json:"spaceId"`
	UserId  string `json:"userId"`
}

func InviteSpaceRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}
	var inviteRequest InviteSpaceRequest

	log.Printf("JoinSpaceRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &inviteRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	receiverUser, userErr := models.GetUser(firestoreClient, firebaseCtx, inviteRequest.UserId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get user: %v", userErr.Error())
		return
	}
	senderUser, userErr := models.GetUser(firestoreClient, firebaseCtx, userId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get user: %v", userErr.Error())
		return
	}

	if !auth.ValidateAddMember(userId, receiverUser) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Not friends; notification request unauhtorized")
		return
	}

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, inviteRequest.SpaceId)
	if spaceErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get space: %v", spaceErr.Error())
		return
	}

	if !auth.IsMember(space, userId) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Not a member of space; add request unauhtorized")
		return
	}

	if auth.IsMember(space, inviteRequest.UserId) {
		httpCtx.Error("Already part of space", fasthttp.StatusBadRequest)
		log.Printf("Already a member of space; add request unauhtorized")
		return
	}

	firestoreClient.Collection("users").Doc(inviteRequest.UserId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayUnion(inviteRequest.SpaceId),
		},
	})
	firestoreClient.Collection("spaces").Doc(inviteRequest.SpaceId).Update(firebaseCtx, []firestore.Update{
		{
			Path:  "spaceRequests",
			Value: firestore.ArrayUnion(inviteRequest.UserId),
		},
	})

	privateUser, privateErr := models.GetPrivateUser(firestoreClient, firebaseCtx, inviteRequest.UserId)
	if privateErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get private user: %v", privateErr.Error())
		return
	}

	var notification notifications.SingleNotification
	notification = notifications.SingleNotification{
		Token: *privateUser.Token,
		Title: senderUser.Name + " invited you to [" + space.Name + "]!",
		Body:  "Accept the invite and join the space",
	}
	if err := notifications.SendSingleNotification(&notification, messagingClient, firebaseCtx); err != nil {
		log.Printf("Failed to send notification: %v", err.Error())
	}

	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Added to Space successfully")
}
