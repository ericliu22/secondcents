package space

import (
	"encoding/json"
	"log"

	"server/internal/core/auth"
	"server/internal/core/models"
	"server/internal/middleware"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
)

type FetchSpaceTokenRequest struct {
	SpaceId string `json:"spaceId"`
}

func FetchSpaceTokenHandler(httpCtx *fasthttp.RequestCtx, firestoreClient *firestore.Client) {
	firebaseCtx := middleware.GetRequestContext(httpCtx)

	var fetchRequest FetchSpaceTokenRequest

	log.Printf("FetchSpaceTokenRequest body: %s\n", string(httpCtx.PostBody()))

	if err := json.Unmarshal(httpCtx.PostBody(), &fetchRequest); err != nil {
		log.Printf("Failed to unmarshal fetchtoken request")
		httpCtx.Error("Invalid request body", fasthttp.StatusBadRequest)
		return
	}

	log.Printf("Parsed spacetoken request: %+v\n", fetchRequest)

	space, err := models.GetSpace(firestoreClient, firebaseCtx, fetchRequest.SpaceId)
	if err != nil {
		log.Printf("Failed to get space from request spaceId")
		httpCtx.Error("Invalid spaceId", fasthttp.StatusBadRequest)
		return
	}

	//This checks if the user is in the space in the first place
	if !auth.ValidateGenerateInviteLink(httpCtx, space) {
		httpCtx.Error("Unauthorized", fasthttp.StatusUnauthorized)
		log.Printf("Unauthenticated request")
		return
	}

	var spaceToken string

	//Checks if inviteLink even exists
	if space.SpaceToken == nil {
		var generateErr error
		spaceToken, generateErr = auth.GenerateSpaceToken(firebaseCtx, firestoreClient, fetchRequest.SpaceId)
		if generateErr != nil {
			httpCtx.Error("Internal server error "+generateErr.Error(), fasthttp.StatusInternalServerError)
			return
		}
	} else {
		spaceToken = *space.SpaceToken
		valid, err := auth.ValidateSpaceToken(firebaseCtx, firestoreClient, spaceToken, fetchRequest.SpaceId)
		//Checks if inviteLink has expired and if it is valid JWT
		if err != nil || !valid {
			var generateErr error
			spaceToken, generateErr = auth.GenerateSpaceToken(firebaseCtx, firestoreClient, fetchRequest.SpaceId)
			if generateErr != nil {
				httpCtx.Error("Internal server error "+generateErr.Error(), fasthttp.StatusInternalServerError)
				return
			}
		}
	}

	httpCtx.SetBodyString(spaceToken)
	httpCtx.SetStatusCode(fasthttp.StatusOK)
}
