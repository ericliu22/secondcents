package models

import (
	"context"
	"time"

	"cloud.google.com/go/firestore"
)

type DBUser struct {
	UserID                 string    `firestore:"userId"`
	Email                  *string   `firestore:"email"`
	DateCreated            time.Time `firestore:"dateCreated"`
	Name                   string    `firestore:"name"`
	Username               string    `firestore:"username"`
	ProfileImagePath       *string   `firestore:"profileImagePath"`
	ProfileImageURL        *string   `firestore:"profileImageUrl"`
	UserColor              *string   `firestore:"userColor"`
	Friends                *[]string `firestore:"friends"`
	IncomingFriendRequests *[]string `firestore:"incomingFriendRequests"`
	OutgoingFriendRequests *[]string `firestore:"outgoingFriendRequests"`
	UserPhoneNumber        *string   `firestore:"userPhoneNumber"`
}

func GetUser(client *firestore.Client, firebaseCtx context.Context, userId string) (*DBUser, error) {
	spaceDoc := client.Collection("users").Doc(userId)

	snapshot, err := spaceDoc.Get(firebaseCtx)
	if err != nil {
		return nil, err
	}

	var user DBUser
	if err := snapshot.DataTo(&user); err != nil {
		return nil, err
	}

	return &user, nil // Return a pointer to DBUser
}
