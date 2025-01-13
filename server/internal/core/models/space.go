package models

import (
	"context"
	"time"

	"cloud.google.com/go/firestore"
)

type DBSpace struct {
	SpaceID          string    `firestore:"spaceId"`
	DateCreated      time.Time `firestore:"dateCreated"`
	Name             string    `firestore:"name"`
	Emoji            string    `firestore:"emoji"`
	ProfileImagePath *string   `firestore:"profileImagePath"`
	ProfileImageURL  *string   `firestore:"profileImageUrl"`
	Members          *[]string `firestore:"members"`
	Admins           *[]string `firestore:"admins"`
	NextWidgetX      *float64  `firestore:"nextWidgetX"`
	NextWidgetY      *float64  `firestore:"nextWidgetY"`
	SpaceToken       *string   `firestore:"spaceToken"`
	PrivateKey       *string   `firestore:"privateKey"`
}

func GetSpace(firestoreClient *firestore.Client, firebaseCtx context.Context, spaceId string) (*DBSpace, error) {
	spaceDoc := firestoreClient.Collection("spaces").Doc(spaceId)

	snapshot, err := spaceDoc.Get(firebaseCtx)
	if err != nil {
		return nil, err
	}

	var space DBSpace
	if err := snapshot.DataTo(&space); err != nil {
		return nil, err
	}

	return &space, nil // Return a pointer to DBSpace
}
