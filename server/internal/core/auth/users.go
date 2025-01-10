package auth

import (
	"log"
	
	"github.com/valyala/fasthttp"
	"server/internal/middleware"
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
