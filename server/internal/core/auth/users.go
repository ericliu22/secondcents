package auth

import (
	"context"
	"log"

	"server/internal/core/models"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
)

func ValidateUser(httpCtx *fasthttp.RequestCtx, userId string) bool {

	authenticatedUserId, authErr := middleware.GetAuthenticatedUserId(httpCtx)
	if authErr != nil {
		log.Printf("Request Unauthorized")
		return false
	}

	if authenticatedUserId != userId {
		log.Printf("AuthenticatedUserId does not match request userId")
		return false
	}

	return true
}

func ValidateUserNotification(senderId string, targetUser *models.DBUser) bool {
	for _, friendId := range *targetUser.Friends {
		if friendId == senderId {
			return true
		}
	}

	return false
}

func ValidateAcceptRequest(senderUser *models.DBUser, receiverUser *models.DBUser) bool {
	var validIncoming, validOutgoing bool
	for _, id := range *receiverUser.IncomingFriendRequests {
		if id == senderUser.UserID {
			validIncoming = true
		}
	}
	for _, id := range *senderUser.OutgoingFriendRequests {
		if id == receiverUser.UserID {
			validOutgoing = true
		}
	}

	return validOutgoing && validIncoming
}

// For now not needed
func ValidSendRequest(senderUserId string, receiverDocRef firestore.DocumentRef, firebaseCtx context.Context) bool {
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
