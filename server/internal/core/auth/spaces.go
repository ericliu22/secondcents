package auth

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/golang-jwt/jwt/v5"
	"github.com/valyala/fasthttp"
	"server/internal/core/models"
	"server/internal/middleware"
)

func GetSpaceKey(ctx context.Context, firestoreClient *firestore.Client, spaceId string) (string, error) {
	spaceDoc := firestoreClient.Collection("spaces").Doc(spaceId)

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
				Path:  "privateKey",
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

func createSpaceJwt(spaceId string, ctx context.Context, firestoreClient *firestore.Client) (string, error) {
	// Define claims
	claims := jwt.MapClaims{
		"sub": spaceId,
		"exp": time.Now().Add(24 * time.Hour).Unix(),
		"iat": time.Now().Unix(),
	}

	// Create the token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Retrieve the private key
	privateKey, err := GetSpaceKey(ctx, firestoreClient, spaceId)
	if err != nil {
		return "", err
	}

	// Decode the Base64-encoded privateKey to []byte
	decodedKey, err := base64.StdEncoding.DecodeString(privateKey)
	if err != nil {
		return "", fmt.Errorf("failed to decode private key: %w", err)
	}

	// Sign the token
	tokenString, err := token.SignedString(decodedKey)
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	return tokenString, nil
}

func ValidateSpaceToken(firebaseCtx context.Context, firestoreClient *firestore.Client, tokenString string, spaceId string) (bool, error) {
	privateKey, err := GetSpaceKey(firebaseCtx, firestoreClient, spaceId)
	if err != nil {
		return false, err
	}
	valid, err := isValidToken(tokenString, privateKey)
	return valid, err
}

func isValidToken(tokenString string, privateKey string) (bool, error) {
	// Decode the Base64-encoded privateKey to []byte
	decodedKey, err := base64.StdEncoding.DecodeString(privateKey)
	if err != nil {
		return false, fmt.Errorf("failed to decode private key: %w", err)
	}

	// Parse the token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Validate the signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}

		// Return the decoded key for validation
		return decodedKey, nil
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

func IsMember(space *models.DBSpace, userId string) bool {
	// Query the document to check if the user is in the 'members' array

	// Check if the userID exists in the array
	for _, member := range *space.Members {
		if member == userId {
			return true
		}
	}

	return false
}

func GenerateSpaceToken(ctx context.Context, firestoreClient *firestore.Client, spaceId string) (string, error) {

	token, err := createSpaceJwt(spaceId, ctx, firestoreClient)
	if err != nil {
		return "", err
	}

	return token, nil
}

func ValidateGenerateInviteLink(httpCtx *fasthttp.RequestCtx, space *models.DBSpace) bool {
	authenticatedUserId, authErr := middleware.GetAuthenticatedUserId(httpCtx)

	if authErr != nil {
		return false
	}

	if !IsMember(space, authenticatedUserId) {
		log.Printf("Unauthorized bum")
		return false
	}

	return true
}

func ValidateSpaceNotifcationRequest(space *models.DBSpace, userId string) bool {
	return IsMember(space, userId)
}
