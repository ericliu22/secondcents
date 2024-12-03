package user

import (
	"encoding/json"
	"log"
	"context"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
)

type AcceptFriendRequest struct {
	SenderUserId string `json:"senderId"`
	ReceiverUserId string `json:"receiverId"`
}

type SendFriendRequest struct {
	SenderUserId string `json:"senderId"`
	ReceiverUserId string `json:"receiverId"`
}

func AcceptFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest AcceptFriendRequest

	log.Printf("AcceptFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}
	
	log.Printf("Parsed friend request: %+v\n", friendRequest)

	senderDocRef := client.Collection("users").Doc(friendRequest.SenderUserId)
	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)

	if (!validRequest(friendRequest.SenderUserId, *receiverDocRef, firebaseCtx)) {
		httpCtx.SetStatusCode(fasthttp.StatusInternalServerError)
		httpCtx.SetBodyString("Failed to parse receiver's document data")
		return
	}

	_, senderErr := senderDocRef.Update(firebaseCtx, []firestore.Update {
		{
			Path: "friends",
			Value: firestore.ArrayUnion(friendRequest.ReceiverUserId),
		},
	})
	if senderErr != nil {
		log.Printf("Parsed friend request: %+v\n", friendRequest)
		return
	}

	_, receiverErr := receiverDocRef.Update(firebaseCtx, []firestore.Update {
		{
			Path: "friends",
			Value: firestore.ArrayUnion(friendRequest.SenderUserId),
		},
	})
	if receiverErr != nil {
		log.Printf("Parsed friend request: %+v\n", friendRequest)
		return
	}
}

func validRequest(senderUserId string, receiverDocRef firestore.DocumentRef, firebaseCtx context.Context) bool {
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
		if id == senderUserId{
			return true
		}
	}

	return false
}


func SendFriendRequestHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {

	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var friendRequest AcceptFriendRequest

	log.Printf("SendFriendRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &friendRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}
	
	log.Printf("Parsed friend request: %+v\n", friendRequest)

	receiverDocRef := client.Collection("users").Doc(friendRequest.ReceiverUserId)

	_, err := receiverDocRef.Update(firebaseCtx, []firestore.Update {
		{
			Path: "incomingFriendRequests",
			Value: firestore.ArrayUnion(friendRequest.SenderUserId),
		},
	})
	if err != nil {
		log.Printf("Parsed friend request: %+v\n", friendRequest)
		return
	}
}
