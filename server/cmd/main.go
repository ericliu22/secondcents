package main

import (
	"context"
	"log"
	"os"

	"firebase.google.com/go"
	"github.com/valyala/fasthttp"
	"server/internal"
	"google.golang.org/api/option"
)

func main() {
	// Initialize Firebase Admin SDK
	credential_path := os.Getenv("FIREBASE_ADMIN_CREDENTIAL_PATH")
	if credential_path == "" {
		log.Fatalf("Firebase credential path not set")
	}
	opt := option.WithCredentialsFile(credential_path)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("error initializing Firebase app: %v", err)
	}

	// Set up the router
	router := internal.SetupRouter(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8000" // Default port if not specified
	}

	    // Start the server
	log.Fatal(fasthttp.ListenAndServe(":"+port, router.Handler))
}

