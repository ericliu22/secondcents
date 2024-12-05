package middleware

import (
	"context"
	"errors"
	"log"

	"firebase.google.com/go/auth"
	"github.com/valyala/fasthttp"
)

func WithAuthClient(authClient *auth.Client) Middleware {
	return func(next fasthttp.RequestHandler) fasthttp.RequestHandler {
		return func(ctx *fasthttp.RequestCtx) {
			ctx.SetUserValue("authClient", authClient)
			next(ctx)
		}
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
		log.Printf("Auth client not found")
		return "", errors.New("authentication client not found")
	}

	// Get the Authorization header
	authHeader := string(ctx.Request.Header.Peek("Authorization"))
	if authHeader == "" {
		log.Printf("Auth beader missing")
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
