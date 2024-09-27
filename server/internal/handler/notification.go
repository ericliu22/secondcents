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
    // Parse incoming JSON
    var fcmReq NotificationRequest
    var notificationRequest NotificationRequest
    if err := json.Unmarshal(ctx.PostBody(), &notificationRequest); err != nil {
        log.Printf("Error parsing JSON: %v", err)
        ctx.Error("Bad request", fasthttp.StatusBadRequest)
        return
    }

    // Initialize FCM messaging client
    client, err := app.Messaging(context.Background())
    if err != nil {
        log.Printf("Error initializing Firebase Messaging: %v", err)
        ctx.Error("Internal server error", fasthttp.StatusInternalServerError)
        return
    }

    // Create FCM message
    message := &messaging.Message{
        Token: fcmReq.token,
        Notification: &messaging.Notification{
            Title: fcmReq.notification.title,
            Body:  fcmReq.notification.body,
        },
	Data: fcmReq.data,
    }

    fmt.Printf("Preparing to send FCM notification: %+v\n", fcmReq)

    // If the image is provided (not nil), set it in the notification
    if fcmReq.notification.image != nil {
        message.Notification.ImageURL = *fcmReq.notification.image
    }

    // Send the message to FCM
    response, err := client.Send(context.Background(), message)
    if err != nil {
        log.Printf("Error sending message to FCM: %v", err)
        ctx.Error("Error sending message", fasthttp.StatusInternalServerError)
        return
    }

    // Return FCM response
    ctx.SetStatusCode(fasthttp.StatusOK)
    ctx.SetBodyString("Message sent successfully: " + response)
}
