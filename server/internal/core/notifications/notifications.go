package notifications

import (
	"context"
	"encoding/json"
	"log"

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

type TopicNotification struct {
	Topic string            `json:"topic"`           // Notification Topic
	Title string            `json:"title"`           // Match the JSON field "title"
	Body  string            `json:"body"`            // Match the JSON field "body"
	Image *string           `json:"image,omitempty"` // Optional image field
	Data  map[string]string `json:"data"`            // Optional data
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
You don't actually call this from the API. The server handles this internally for security reasons
*/
func SendTopicNotification(notification *TopicNotification, messagingClient *messaging.Client, context context.Context) error {
	// Build the FCM message
	msg := &messaging.Message{
		Topic: notification.Topic,
		// The "Notification" portion is what shows up in the system tray on most platforms
		Notification: &messaging.Notification{
			Title: notification.Title,
			Body:  notification.Body,
		},
		// Additional key-value pairs for custom logic on the client
		Data: notification.Data,
	}

	// If an image was provided, include it in the notification
	if notification.Image != nil && *notification.Image != "" {
		msg.Notification.ImageURL = *notification.Image
	}

	// Send the message
	response, err := messagingClient.Send(context, msg)
	if err != nil {
		log.Printf("Error sending topic notification to '%s': %v\n", notification.Topic, err)
		return err
	}

	// For debugging: FCM returns a message ID if successful.
	log.Printf("Successfully sent notification to topic '%s'. FCM response: %s\n", notification.Topic, response)
	return nil
}
