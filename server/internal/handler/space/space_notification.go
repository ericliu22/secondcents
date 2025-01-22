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

// NotificationRequest represents the full request structure
type SpaceNotificationRequest struct {
	Type    string            `json:"type"`
	SpaceId string            `json:"spaceId"`
	Body    string            `json:"body"`
	Data    map[string]string `json:"data"` // Optional data
}

func SpaceNotificationHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}

	var notificationRequest SpaceNotificationRequest

	log.Printf("SpaceNotificationRequest body: %s\n", string(httpCtx.PostBody()))
	if err := json.Unmarshal(httpCtx.PostBody(), &notificationRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed SpaceNotificationRequest: %+v\n", notificationRequest)

	space, spaceErr := models.GetSpace(firestoreClient, firebaseCtx, notificationRequest.SpaceId)
	if spaceErr != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	if !auth.ValidateSpaceNotifcationRequest(space, userId) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}

	user, userErr := models.GetUser(firestoreClient, firebaseCtx, userId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get user: %v", userErr.Error())
		return
	}

	var notification notifications.TopicNotification
	switch notificationRequest.Type {
	case "chat":
		notification = notifications.TopicNotification{

			Topic: notificationRequest.SpaceId,
			Title: "[" + space.Name + "] " + user.Username,
			Body:  notificationRequest.Body,
			Data:  notificationRequest.Data,
		}
	case "emoji":
		notification = notifications.TopicNotification{
			Topic: notificationRequest.SpaceId,
			Title: "[" + space.Name + "] " + user.Username,
			Body:  notificationRequest.Body,
			Data:  notificationRequest.Data,
		}
	case "widget":
		notification = notifications.TopicNotification{
			Topic: notificationRequest.SpaceId,
			Title: "[" + space.Name + "] " + user.Username,
			Body:  notificationRequest.Body,
			Data:  notificationRequest.Data,
		}
	case "chatWidget":

		chat, chatErr := models.GetChat(firestoreClient, firebaseCtx, notificationRequest.SpaceId, notificationRequest.Data["widgetId"])
		if chatErr != nil {
			httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
			log.Printf("Failed to get user: %v", userErr.Error())
			return
		}

		notification = notifications.TopicNotification{
			Topic: notificationRequest.SpaceId,
			Title: "[" + space.Name + "/" + chat.Name + "] " + user.Username,
			Body:  notificationRequest.Body,
			Data:  notificationRequest.Data,
		}
	default:
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}
	if err := notifications.SendTopicNotification(&notification, messagingClient, firebaseCtx); err != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusInternalServerError)
		log.Printf("Failed to get user: %v", err.Error())
		return
	}
	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Notification sent successfully.")
}
