package handler

import (
    "context"
    "encoding/json"
    "log"
    "fmt"

    "firebase.google.com/go/messaging"
    "firebase.google.com/go"
    "github.com/valyala/fasthttp"
)

type Notification struct {
	title	string `json:"title"`
	body	string `json:"body"`
	image	*string `json:"image"`
}

type NotificationRequest struct {
    token        string            `json:"token"` 
    notification Notification      `json:"notification"`           // The notification content
    data         map[string]string `json:"data,omitempty"`         // Optional data
}

func NotificationHandler(ctx *fasthttp.RequestCtx, app *firebase.App) {
    var notificationReq NotificationRequest

    // Parse the request body (Fasthttp uses ctx.PostBody())
    if err := json.Unmarshal(ctx.PostBody(), &notificationReq); err != nil {
        ctx.Error("Invalid request body", fasthttp.StatusBadRequest)
        return
    }

    // Validate that token is present
    if notificationReq.token == "" {
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
        Token: notificationReq.token,
        Notification: &messaging.Notification{
            Title: notificationReq.notification.title,
            Body:  notificationReq.notification.body,
        },
        Data: notificationReq.data,
    }

    // Add image if present
    if notificationReq.notification.image != nil {
        message.Notification.ImageURL = *notificationReq.notification.image
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
