package user

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

type UserNotificationRequest struct {
	Type   string            `json:"type"`
	UserId string            `json:"userId"`
	Data   map[string]string `json:"data"`
}

func UserNotificationHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	userId, err := middleware.GetAuthenticatedUserId(httpCtx)
	if err != nil {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		return
	}

	var notificationRequest UserNotificationRequest

	log.Printf("UserNotificationRequest body: %s\n", string(httpCtx.PostBody()))
	if err := json.Unmarshal(httpCtx.PostBody(), &notificationRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed UserNotificationRequest: %+v\n", notificationRequest)

	user, userErr := models.GetUser(firestoreClient, firebaseCtx, userId)
	if userErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get user: %v", userErr.Error())
		return
	}

	if !auth.ValidateUserNotification(userId, user) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Not friends; notification request unauhtorized")
		return
	}

	privateUser, privateErr := models.GetPrivateUser(firestoreClient, firebaseCtx, notificationRequest.UserId)
	if privateErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get privateUser: %v", privateErr.Error())
		return
	}

	//We need to check privateUser.Token here to make sure it isn't nil
	if privateUser.Token == nil || *privateUser.Token == "" {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get deviceToken for user: %v", notificationRequest.UserId)
		return
	}

	var notification notifications.SingleNotification
	switch notificationRequest.Type {
	case "tickle":
		notification = notifications.SingleNotification{
			Token: *privateUser.Token,
			Title: user.Name,
			Body:  user.Name + " tickled you 🤗",
			Image: user.ProfileImageURL,
		}
	case "multiTickle":
		notification = notifications.SingleNotification{
			Token: *privateUser.Token,
			Title: user.Name,
			Body:  user.Name + " tickled you" + notificationRequest.Data["count"] + " times 🤗",
			Image: user.ProfileImageURL,
		}
	default:
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}
	if err := notifications.SendSingleNotification(&notification, messagingClient, firebaseCtx); err != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusInternalServerError)
		log.Printf("Failed to send notification: %v", err.Error())
		return
	}
	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Notification sent successfully.")
}
