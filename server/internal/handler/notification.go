package handler

import (
	"context"
	"encoding/json"
	"log"

	"firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/valyala/fasthttp"
)

// Notification represents the notification structure
type Notification struct {
	Title string  `json:"title"`           // Match the JSON field "title"
	Body  string  `json:"body"`            // Match the JSON field "body"
	Image *string `json:"image,omitempty"` // Optional image field
}

// NotificationRequest represents the full request structure
type NotificationRequest struct {
	Token        string            `json:"token"`        // Single token
	Notification Notification      `json:"notification"` // The notification content
	Data         map[string]string `json:"data"`         // Optional data
}

func NotificationHandler(ctx *fasthttp.RequestCtx, app *firebase.App) {
	var notificationReq NotificationRequest

	// Parse the request body (Fasthttp uses ctx.PostBody())
	log.Printf("PostBody: %s\n", string(ctx.PostBody()))

	if err := json.Unmarshal(ctx.PostBody(), &notificationReq); err != nil {
		ctx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed notification request: %+v\n", notificationReq)

	// Validate that token is present
	if notificationReq.Token == "" {
		ctx.Error("Token is required", fasthttp.StatusBadRequest)
		return
	}

	// Initialize FCM messaging client
	client, err := app.Messaging(context.Background())
	if err != nil {
		log.Printf("Error initializing Firebase Messaging: %v\n", err)
		ctx.Error("Internal server error", fasthttp.StatusInternalServerError)
		return
	}

	// Create FCM message
	message := &messaging.Message{
		Token: notificationReq.Token,
		Notification: &messaging.Notification{
			Title: notificationReq.Notification.Title,
			Body:  notificationReq.Notification.Body,
		},
		Data: notificationReq.Data,
	}

	// Add image if present
	if notificationReq.Notification.Image != nil {
		message.Notification.ImageURL = *notificationReq.Notification.Image
	}

	// Send the notification to the token
	response, err := client.Send(context.Background(), message)
	if err != nil {
		ctx.Error("Failed to send notification", fasthttp.StatusInternalServerError)
		return
	}

	log.Printf("Sent notification to token: %s\n", response)

	// Success response
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.SetBodyString("Notification sent successfully")
}
