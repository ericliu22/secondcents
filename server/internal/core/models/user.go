package models

import (
	"cloud.google.com/go/firestore"
	"time"
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
