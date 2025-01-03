package auth

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/valyala/fasthttp"
	"github.com/golang-jwt/jwt/v5"
	"server/internal/middleware"
)

func GetSpaceKey(ctx context.Context, client *firestore.Client, spaceId string) (string, error) {
	spaceDoc := client.Collection("spaces").Doc(spaceId)

	docSnapshot, err := spaceDoc.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("failed to access space document: %w", err)
	}

	var privateKey string
	if docSnapshot.Exists() {
		// Check if the privateKey field exists
		data := docSnapshot.Data()
		if key, ok := data["privateKey"].(string); ok && key != "" {
			privateKey = key
		}
	}

	// Generate a new private key if it doesn't exist
	if privateKey == "" {
		privateKey = generatePrivateKey()
		_, err := spaceDoc.Update(ctx, []firestore.Update{
			{
				Path: "privateKey",
				Value: privateKey,
			},
		})
		if err != nil {
			return "", fmt.Errorf("failed to set private key: %w", err)
		}
		log.Printf("Generated and saved new private key for space %s", spaceId)
	} else {
		log.Printf("Retrieved existing private key for space %s", spaceId)
	}

	return privateKey, nil
}

// Generate a random private key (base64 encoded)
func generatePrivateKey() string {
	key := make([]byte, 32) // 256-bit key
	_, err := rand.Read(key)
	if err != nil {
		log.Fatalf("Failed to generate random private key: %v", err)
	}
	return base64.StdEncoding.EncodeToString(key)
}

func createSpaceJwt(spaceId string, ctx context.Context, client *firestore.Client) (string, error) {
	// Define claims
	claims := jwt.MapClaims{
		"sub": spaceId,
		"exp": time.Now().Add(24 * time.Hour).Unix(),
		"iat": time.Now().Unix(),
	}

	// Create the token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	privateKey, err := GetSpaceKey(ctx, client, spaceId)
	if err != nil {

		return "", err
	}
	// Sign the token
	tokenString, err := token.SignedString(privateKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func ValidateSpaceJwt(tokenString string, spaceId string) error {
	return nil
}

func isValidToken(tokenString string, privateKey string) (bool, error) {
	// Parse the token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Validate the signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		// Return the secret key for validation
		return privateKey, nil
	})
	if err != nil {
		return false, err
	}

	// Extract claims and check validity
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Extract the expiration time
		if exp, ok := claims["exp"].(float64); ok {
			expirationTime := time.Unix(int64(exp), 0)
			isValid := time.Now().Before(expirationTime)
			return isValid, nil
		}
		return false, fmt.Errorf("expiration (exp) claim missing or invalid")
	}

	return false, fmt.Errorf("invalid token")
}

func isMember(data map[string]interface{}, userId string) (bool, error) {
	// Query the document to check if the user is in the 'members' array

	members, exists := data["members"]
	if !exists {
		return false, fmt.Errorf("field 'members' does not exist")
	}

	// Check if 'members' is an array
	array, ok := members.([]interface{})
	if !ok {
		return false, fmt.Errorf("'members' is not an array")
	}

	// Check if the userID exists in the array
	for _, member := range array {
		if member == userId {
			return true, nil
		}
	}

	return false, nil
}

func RegenerateInviteLink(ctx context.Context, client *firestore.Client, spaceId string) (string, error) {

	token, err := createSpaceJwt(spaceId, ctx, client)
	if err != nil {
		return "", err
	}

	return token, nil
}

func AuthenticatedInviteLink(httpCtx *fasthttp.RequestCtx, data map[string]interface{}) bool {
	authenticatedUserId, authErr := middleware.GetAuthenticatedUserId(httpCtx)

	if authErr != nil {
		return false
	}

	isMember, membershipErr := isMember(data, authenticatedUserId)
	if membershipErr != nil {
		log.Printf(membershipErr.Error())
		return false
	}

	if isMember {
		log.Printf("Unauthorized bum")
		return false
	}

	return true
}
