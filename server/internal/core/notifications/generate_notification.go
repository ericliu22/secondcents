package notifications

import (
	"math/rand"
)

func GenerateAcceptRequestNotification(receiverName string) string {

	var acceptRequestMessages = []string{
		" accepted your desperate plea to be friends",
		": \"Fine I guess I'll be your friend🙄\"",
	}

	var body string = acceptRequestMessages[rand.Intn(len(acceptRequestMessages))]

	return receiverName + body
}

func GenerateSendRequestNotification(senderName string) string {

	var friendRequestMessages = []string{
		"BEGS to be your friend",
		"wants to be your friend SO BADLY",
		"DESPERATELY wants to be your friend",
		"is feeling lonely... Pls be their friend?",
		"craves your friendship",
		"longs for your company",
		"eagerly awaits your friendship",
		"yearns for your companionship",
		"feels a strong need for your friendship",
		"desperately wishes to be close to you",
		"wants to be friends more than anything",
	}

	var body string = friendRequestMessages[rand.Intn(len(friendRequestMessages))]

	return senderName + " " + body
}
