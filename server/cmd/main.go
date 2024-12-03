package main

import (
	"context"
	"log"
	"os"

	"server/internal/middleware"
	"server/internal/routes"

	"firebase.google.com/go"
	"github.com/valyala/fasthttp"
	"google.golang.org/api/option"
)

func main() {
	// Initialize Firebase Admin SDK
	logFile, err := middleware.SetupLogging()
	if err != nil {
		log.Fatalf("Failed to set up logging: %v", err)
	}
	defer logFile.Close()

	credential_path := os.Getenv("FIREBASE_ADMIN_CREDENTIAL_PATH")
	if credential_path == "" {
		log.Fatalf("Firebase credential path not set")
	}

	opt := option.WithCredentialsFile(credential_path)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing Firebase app: %v", err)
	}

	client, err := app.Firestore(context.Background())
	if err != nil {
		log.Fatalf("Error initializing Firestore client: %v", err)
	}
	defer client.Close()

	coreRouter := routes.SetupCoreRouter(app, client)

	authClient, err := app.Auth(context.Background())
	if err != nil {
		log.Fatalf("Error initializing FirestoreAuth client: %v", err)
	}

	handler := middleware.ChainMiddleware(
		coreRouter.Handler,
		middleware.WithAuthClient(authClient),
		middleware.WithRequestContext(),
	)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port if not specified
	}

	// Start the server
	log.Println("Starting server...")
	log.Fatal(fasthttp.ListenAndServe(":"+port, handler))
}
