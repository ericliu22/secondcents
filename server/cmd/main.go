package main

import (
	"context"
	"log"
	"os"
	"time"

	"firebase.google.com/go"
	"github.com/valyala/fasthttp"
	"server/internal"
	"google.golang.org/api/option"
)

func setupLogging() (*os.File, error) {
    logFileName := "logs/" time.Now().Format("2006-01-02") + ".log"
    logFile, err := os.OpenFile(logFileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        return nil, err
    }
    log.SetOutput(logFile)
    return logFile, nil
}

func main() {
	// Initialize Firebase Admin SDK
	setupLogging()
	logFile, err := setupLogging()
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

	// Set up the router
	router := internal.SetupRouter(app)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port if not specified
	}

	    // Start the server
	log.Println("Starting server...")
	log.Fatal(fasthttp.ListenAndServe(":"+port, router.Handler))
}

