package space

import (
	"log"
	"encoding/json" 

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
	"server/internal/core/auth"
)

type GenerateInviteLinkRequest struct {
	SpaceId string `json:"spaceId"`
}

func GenerateInviteLinkHandler(httpCtx *fasthttp.RequestCtx, client *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var inviteRequest GenerateInviteLinkRequest

	log.Printf("InviteLinkRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &inviteRequest); err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed friend request: %+v\n", inviteRequest)

	spaceDoc := client.Collection("spaces").Doc(inviteRequest.SpaceId)

	snapshot, err := spaceDoc.Get(firebaseCtx)
	if err != nil {
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}
	space := snapshot.Data()

	//This checks if the user is in the space in the first place
	if (!auth.AuthenticatedInviteLink(httpCtx, client, firebaseCtx, space)) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Unauthenticated request")
		return
	}


	var inviteLink string

	data, exists := space["inviteLink"]
	inviteLink, ok := data.(string)
	if !ok {
		log.Printf("'inviteLink' is not a string")
		httpCtx.Error("Internal server error", fasthttp.StatusInternalServerError)
		return
	}
	
	//Checks if inviteLink even exists
	if !exists {
		inviteLink = auth.RegenerateInviteLink(firebaseCtx, inviteRequest.SpaceId)
	}

	//Checks if inviteLink has expird
	if err := auth.ValidateSpaceJwt(inviteLink, inviteRequest.SpaceId); err != nil {
		inviteLink = auth.RegenerateInviteLink(firebaseCtx, inviteRequest.SpaceId)
	}

	httpCtx.SetBodyString(inviteLink)
}
