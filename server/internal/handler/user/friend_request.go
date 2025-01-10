package user

import (
	"context"
	"encoding/json"
	"log"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
	"server/internal/core/auth"
)

type FriendRequest struct {
	SenderUserId   string `json:"senderId"`
	ReceiverUserId string `json:"receiverId"`
}

func AcceptFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {


	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("AcceptFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if (!auth.ValidateUser(httpCtx, friendRequest.ReceiverUserId)) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		return
	}



	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)

	if !validAcceptRequest(friendRequest.SenderUserId, senderDocRef, friendRequest.ReceiverUserId, receiverDocRef, firebaseCtx) {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse receiver's document data")
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
}

func validAcceptRequest(senderUserId string, senderDocRef *firestore.DocumentRef, receiverUserId string, receiverDocRef *firestore.DocumentRef, firebaseCtx context.Context) bool {

	receiverDocumentSnapshot, fetchDocErr := receiverDocRef.Get(firebaseCtx)
	if fetchDocErr != nil {
		return false
	}

	var receiverData map[string]interface{}
	if err := receiverDocumentSnapshot.DataTo(&receiverData); err != nil {
		return false
	}

	incomingFriendRequests, ok := receiverData["incomingFriendRequests"].([]interface{})
	if !ok {
		return false
	}

	senderDocumentSnapshot, fetchDocErr := senderDocRef.Get(firebaseCtx)
	if fetchDocErr != nil {
		return false
	}

	var senderData map[string]interface{}
	if err := senderDocumentSnapshot.DataTo(&senderData); err != nil {
		return false
	}

	outgoingFriendRequests, ok := senderData["outgoingFriendRequests"].([]interface{})
	if !ok {
		return false
	}

	var validIncoming bool = false
	var validOutgoing bool = false

	for _, id := range incomingFriendRequests {
		if id == senderUserId {
			validIncoming = true
		}
	}
	for _, id := range outgoingFriendRequests {
		if id == receiverUserId {
			validOutgoing = true
		}
	}

	return validOutgoing && validIncoming
}

// For now not needed
func validSendRequest(senderUserId string, receiverDocRef firestore.DocumentRef, firebaseCtx context.Context) bool {
	documentSnapshot, fetchDocErr := receiverDocRef.Get(firebaseCtx)
	if fetchDocErr != nil {
		return false
	}

	var data map[string]interface{}
	if err := documentSnapshot.DataTo(&data); err != nil {
		return false
	}

	incomingFriendRequests, ok := data["incomingFriendRequests"].([]interface{})
	if !ok {
		return false
	}

	for _, id := range incomingFriendRequests {
		if id == senderUserId {
			return true
		}
	}

	return false
}

func SendFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("SendFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		log.Printf("Invalid request body")
		return
	}

	if (!auth.ValidateUser(httpCtx, friendRequest.SenderUserId)) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)
	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)

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
}

func UnsendFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	if (!auth.ValidateUser(httpCtx, friendRequest.SenderUserId)) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	log.Printf("UnsendFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)
	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)

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

func RemoveFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("FriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if (!auth.ValidateUser(httpCtx, friendRequest.ReceiverUserId)) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)

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

func DeclineFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest FriendRequest

	log.Printf("DeclineFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", friendRequest)

	if (!auth.ValidateUser(httpCtx, friendRequest.ReceiverUserId)) {
		httpCtx.SetStatusCode(fasthttp.StatusUnauthorized)
		httpCtx.SetBodyString("Unauthorized user friend request")
		log.Printf("Unauthenticated request")
		return
	}

	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)

	if !validAcceptRequest(friendRequest.SenderUserId, senderDocRef, friendRequest.ReceiverUserId, receiverDocRef, firebaseCtx) {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse receiver's document data")
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
