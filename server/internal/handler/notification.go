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
	token	string `json:"token"`
	image	*string `json:"image"`
}

func NotificationHandler(ctx *fasthttp.RequestCtx, app *firebase.App) {
    // Parse incoming JSON
    var fcmReq Notification
    if err := json.Unmarshal(ctx.PostBody(), &fcmReq); err != nil {
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
            Title: fcmReq.title,
            Body:  fcmReq.body,
        },
    }

    fmt.Printf("Preparing to send FCM notification: %+v\n", fcmReq)

    // If the image is provided (not nil), set it in the notification
    if fcmReq.image != nil {
        message.Notification.ImageURL = *fcmReq.image
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
