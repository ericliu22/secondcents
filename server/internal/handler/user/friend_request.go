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

type FriendRequest struct {
	SenderUserId   string `json:"senderId"`
	ReceiverUserId string `json:"receiverId"`
}

func AcceptFriendRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("AcceptFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if !auth.ValidateUser(httpCtx, friendRequest.ReceiverUserId) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		return
	}

	senderDocRef := firestoreClient.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := firestoreClient.Collection("users").Doc(friendRequest.ReceiverUserId)

	senderUser, senderFetchErr := models.GetUser(firestoreClient, firebaseCtx, friendRequest.SenderUserId)
	if senderFetchErr != nil {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse sender's document data")
		return
	}

	receiverUser, receiverFetchErr := models.GetUser(firestoreClient, firebaseCtx, friendRequest.ReceiverUserId)
	if receiverFetchErr != nil {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse receiver's document data")
		return
	}

	if !auth.ValidateAcceptRequest(senderUser, receiverUser) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Not a valid accept request")
		return
	}

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "friends",
			Value: firestore.ArrayUnion(friendRequest.ReceiverUserId),
		},
		{
			Path:  "outgoingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Failed to update receiver friends list: %s", senderErr.Error())
		return
	}

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "friends",
			Value: firestore.ArrayUnion(friendRequest.SenderUserId),
		},
		{
			Path:  "incomingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Failed to update receiver friends list: %s", receiverErr.Error())
		return
	}

	privateUser, privateErr := models.GetPrivateUser(firestoreClient, firebaseCtx, friendRequest.SenderUserId)
	if privateErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get privateUser: %v", privateErr.Error())
		return
	}

	//We need to check privateUser.Token here to make sure it isn't nil
	if privateUser.Token == nil || *privateUser.Token == "" {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get deviceToken for user: %v", friendRequest.SenderUserId)
		return
	}

	var notification notifications.SingleNotification
	notification = notifications.SingleNotification{
		Token: *privateUser.Token,
		Title: receiverUser.Name,
		Body:  notifications.GenerateAcceptRequestNotification(receiverUser.Name),
		Image: receiverUser.ProfileImageURL,
	}
	if err := notifications.SendSingleNotification(&notification, messagingClient, firebaseCtx); err != nil {
		log.Printf("Failed to send notification: %v", err.Error())
	}
	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Accepted friend request")
}

func SendFriendRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client, messagingClient *messaging.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("SendFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		log.Printf("Invalid request body")
		return
	}

	if !auth.ValidateUser(httpCtx, friendRequest.SenderUserId) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	receiverDocRef := firestoreClient.Collection("users").Doc(friendRequest.ReceiverUserId)
	senderDocRef := firestoreClient.Collection("users").Doc(friendRequest.SenderUserId)

	senderUser, senderFetchErr := models.GetUser(firestoreClient, firebaseCtx, friendRequest.SenderUserId)
	if senderFetchErr != nil {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse sender's document data")
		return
	}

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "incomingFriendRequests",
			Value: firestore.ArrayUnion(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Failed to update incomingFriendRequests: %s", receiverErr.Error())
		return
	}

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "outgoingFriendRequests",
			Value: firestore.ArrayUnion(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Failed to update outgoingFriendRequests: %s", senderErr.Error())
		return
	}

	privateUser, privateErr := models.GetPrivateUser(firestoreClient, firebaseCtx, friendRequest.ReceiverUserId)
	if privateErr != nil {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get privateUser: %v", privateErr.Error())
		return
	}

	//We need to check privateUser.Token here to make sure it isn't nil
	if privateUser.Token == nil || *privateUser.Token == "" {
		httpCtx.Error("Internal server error", fasthttp.StatusBadRequest)
		log.Printf("Failed to get deviceToken for user: %v", friendRequest.SenderUserId)
		return
	}

	var notification notifications.SingleNotification
	notification = notifications.SingleNotification{
		Token: *privateUser.Token,
		Title: senderUser.Name,
		Body:  notifications.GenerateSendRequestNotification(senderUser.Name),
		Image: senderUser.ProfileImageURL,
	}
	if err := notifications.SendSingleNotification(&notification, messagingClient, firebaseCtx); err != nil {
		log.Printf("Failed to send notification: %v", err.Error())
	}
	httpCtx.SetStatusCode(fasthttp.StatusOK)
	httpCtx.SetBodyString("Accepted friend request")
}

func UnsendFriendRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("UnsendFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if !auth.ValidateUser(httpCtx, friendRequest.SenderUserId) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	receiverDocRef := firestoreClient.Collection("users").Doc(friendRequest.ReceiverUserId)
	senderDocRef := firestoreClient.Collection("users").Doc(friendRequest.SenderUserId)

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "incomingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Failed to update incomingFriendRequests: %s", receiverErr.Error())
		return
	}

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "outgoingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Failed to update outgoingFriendRequests: %s", senderErr.Error())
		return
	}
}

func RemoveFriendRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("FriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if !auth.ValidateUser(httpCtx, friendRequest.SenderUserId) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	senderDocRef := firestoreClient.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := firestoreClient.Collection("users").Doc(friendRequest.ReceiverUserId)

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "friends",
			Value: firestore.ArrayRemove(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Failed to update receiver friends list: %s", senderErr.Error())
		return
	}

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "friends",
			Value: firestore.ArrayRemove(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Failed to update receiver friends list: %s", receiverErr.Error())
		return
	}
}

func DeclineFriendRequestHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("DeclineFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if !auth.ValidateUser(httpCtx, friendRequest.ReceiverUserId) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	senderDocRef := firestoreClient.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := firestoreClient.Collection("users").Doc(friendRequest.ReceiverUserId)

	senderUser, senderFetchErr := models.GetUser(firestoreClient, firebaseCtx, friendRequest.SenderUserId)
	if senderFetchErr != nil {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse sender's document data")
		return
	}

	receiverUser, receiverFetchErr := models.GetUser(firestoreClient, firebaseCtx, friendRequest.ReceiverUserId)
	if receiverFetchErr != nil {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse receiver's document data")
		return
	}

	if !auth.ValidateAcceptRequest(senderUser, receiverUser) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Not a valid decline request")
		return
	}

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "outgoingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Failed to update receiver friends list: %s", senderErr.Error())
		return
	}

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update{
		{
			Path:  "incomingFriendRequests",
			Value: firestore.ArrayRemove(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Failed to update receiver friends list: %s", receiverErr.Error())
		return
	}
}
