package models

import (
	"context"

	"cloud.google.com/go/firestore"
)

type DBChat struct {
	Id string `firestore:"id"`
	SpaceId string `firestore:"spaceId"`
	Name string `firestore:"name"`
	Members *[]string `firestore:"members"`
	LastSender string `firestore:"lastSender"`
    
}

func GetChat(firestoreClient *firestore.Client, firebaseCtx context.Context, spaceId string, chatId string) (*DBChat, error) {
	chatDoc := firestoreClient.Collection("spaces").Doc(spaceId).Collection("chats").Doc(chatId)

	snapshot, err := chatDoc.Get(firebaseCtx)
	if err != nil {
		return nil, err
	}

	var chat DBChat
	if err := snapshot.DataTo(&chat); err != nil {
		return nil, err
	}

	return &chat, nil
}
