package models

import (
	"context"
	"time"

	"cloud.google.com/go/firestore"
)

type DBUser struct {
	UserID                 string    `firestore:"userId"`
	DateCreated            time.Time `firestore:"dateCreated"`
	Name                   string    `firestore:"name"`
	Username               string    `firestore:"username"`
	ProfileImagePath       *string   `firestore:"profileImagePath"`
	ProfileImageURL        *string   `firestore:"profileImageUrl"`
	UserColor              *string   `firestore:"userColor"`
	Friends                *[]string `firestore:"friends"`
	IncomingFriendRequests *[]string `firestore:"incomingFriendRequests"`
	OutgoingFriendRequests *[]string `firestore:"outgoingFriendRequests"`
}

type PrivateUser struct {
	Email           *string `firestore:"email"`
	UserPhoneNumber *string `firestore:"email"`
	Token           *string `firestore:"token"`
}

func GetUser(firestoreClient *firestore.Client, firebaseCtx context.Context, userId string) (*DBUser, error) {
	spaceDoc := firestoreClient.Collection("users").Doc(userId)

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

func GetPrivateUser(firestoreClient *firestore.Client, firebaseCtx context.Context, userId string) (*PrivateUser, error) {
	spaceDoc := firestoreClient.Collection("usersPrivate").Doc(userId)

	snapshot, err := spaceDoc.Get(firebaseCtx)
	if err != nil {
		return nil, err
	}

	var privateUser PrivateUser
	if err := snapshot.DataTo(&privateUser); err != nil {
		return nil, err
	}

	return &privateUser, nil // Return a pointer to PrivateUser
}
