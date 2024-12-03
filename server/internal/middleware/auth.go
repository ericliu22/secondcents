package middleware

import (
	"context"
	"log"
	"errors"

	"firebase.google.com/go/auth"
	"github.com/valyala/fasthttp"
)

func ValidateFirebaseToken(httpCtx *fasthttp.RequestCtx, authClient *auth.Client) (string, int) {
	// Get the token from the Authorization header
	authHeader := string(httpCtx.Request.Header.Peek("Authorization"))
	if authHeader == "" {
		return "", fasthttp.StatusBadRequest
	}

	// Extract the Bearer token
	idToken := authHeader[len("Bearer "):]

	// Verify the token
	token, err := authClient.VerifyIDToken(context.Background(), idToken)
	if err != nil {
		log.Printf("Error verifying ID token: %v\n", err)
		return "", fasthttp.StatusUnauthorized
	}

	// Return the user ID from the token
	return token.UID, 200
}

func WithAuthClient(authClient *auth.Client, next fasthttp.RequestHandler) fasthttp.RequestHandler {
	return func(ctx *fasthttp.RequestCtx) {
		// Inject the authClient into the request context
		ctx.SetUserValue("authClient", authClient)

		// Call the next handler
		next(ctx)
	}
}

// Helper function to retrieve authClient from the request context
func GetAuthClient(ctx *fasthttp.RequestCtx) *auth.Client {
	if value := ctx.UserValue("authClient"); value != nil {
		if authClient, ok := value.(*auth.Client); ok {
			return authClient
		}
	}
	return nil // Return nil if authClient is not set
}

func GetAuthenticatedUserId(ctx *fasthttp.RequestCtx) (string, error) {
	// Retrieve the authClient from the request context
	authClient := GetAuthClient(ctx)
	if authClient == nil {
		return "", errors.New("authentication client not found")
	}

	// Get the Authorization header
	authHeader := string(ctx.Request.Header.Peek("Authorization"))
	if authHeader == "" {
		return "", errors.New("authorization header is missing")
	}

	// Extract the Bearer token
	idToken := authHeader[len("Bearer "):]

	// Validate the token
	token, err := authClient.VerifyIDToken(context.Background(), idToken)
	if err != nil {
		log.Printf("Error verifying ID token: %v\n", err)
		return "", errors.New("invalid or expired token")
	}

	// Return the authenticated user's ID
	return token.UID, nil
}
