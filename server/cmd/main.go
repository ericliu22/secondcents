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
    opt := option.WithCredentialsFile("path/to/serviceAccountKey.json")
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

