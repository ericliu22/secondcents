package notifications

import (
	"context"
	"log"
	"server/internal/core/models"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
)

// Single Notification represents notification to a single user
type SingleNotification struct {
	Token string            `json:"token"`           // Device Token
	Title string            `json:"title"`           // Match the JSON field "title"
	Body  string            `json:"body"`            // Match the JSON field "body"
	Image *string           `json:"image,omitempty"` // Optional image field
	Data  map[string]string `json:"data"`            // Optional data
}

type SpaceNotification struct {
	SpaceId string            `json:"spaceId"`         // Notification Topic
	Title   string            `json:"title"`           // Match the JSON field "title"
	Body    string            `json:"body"`            // Match the JSON field "body"
	Image   *string           `json:"image,omitempty"` // Optional image field
	Data    map[string]string `json:"data"`            // Optional data
}

/*
You don't actually call this from the API. The server handles this internally for security reasons
*/
func SendSingleNotification(notification *SingleNotification, messagingClient *messaging.Client, ctx context.Context) error {
	// Build the FCM message
	msg := &messaging.Message{
		Token: notification.Token,
		Notification: &messaging.Notification{
			Title: notification.Title,
			Body:  notification.Body,
		},
		Data: notification.Data,
	}

	// If an image was provided, include it
	if notification.Image != nil && *notification.Image != "" {
		msg.Notification.ImageURL = *notification.Image
	}

	// Send the message
	response, err := messagingClient.Send(ctx, msg)
	if err != nil {
		log.Printf("Error sending single notification to token '%s': %v\n", notification.Token, err)
		return err
	}

	log.Printf("Successfully sent notification to token '%s'. FCM response: %s\n", notification.Token, response)
	return nil
}

/*
DEPRECATED DON'T USE THIS IT'S NOT SECURE
*/
func SendSpaceNotification(notification *SpaceNotification, space *models.DBSpace, messagingClient *messaging.Client, firestoreClient *firestore.Client, firebaseCtx context.Context) error {

	for _, member := range *space.Members {
		privateUser, privateErr := models.GetPrivateUser(firestoreClient, firebaseCtx, member)
		if privateErr != nil {
			return privateErr
		}
		if privateUser.Token == nil {
			continue
		}

		var notification SingleNotification
		notification = SingleNotification{
			Token: *privateUser.Token,
			Title: notification.Title,
			Body:  notification.Body,
			Image: notification.Image,
		}
		SendSingleNotification(&notification, messagingClient, firebaseCtx)
	}
	return nil
}
