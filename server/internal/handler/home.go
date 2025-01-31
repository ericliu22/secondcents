package handler

import (
	"log"
	"path/filepath"
	"encoding/json"

	"github.com/valyala/fasthttp"
)

// HomeHandler handles the root path
func HomeHandler(ctx *fasthttp.RequestCtx) {
	absPath, err := filepath.Abs("server/internal/static/index.html")
	if err != nil {
		log.Printf("Failed to resolve absolute path: %v", err)
		ctx.SetStatusCode(fasthttp.StatusInternalServerError)
		ctx.SetBodyString("Internal server error")
		return
	}
	ctx.SendFile(absPath)
}

// VersionOneHandler handles the root path
func VersionOneHandler(ctx *fasthttp.RequestCtx) {
	ctx.Redirect("https://www.youtube.com/watch?v=dQw4w9WgXcQ", fasthttp.StatusFound)
}

type VersionResponse struct {
    MinimumVersion string `json:"minimum_version"`
}

func VersionHandler(ctx *fasthttp.RequestCtx) {
    ctx.SetContentType("application/json; charset=utf-8")

    // Example version. In reality you might read it from an env var or config.
    response := VersionResponse{MinimumVersion: "0.1.0"}

    // Encode to JSON
    if jsonBytes, err := json.Marshal(response); err == nil {
        ctx.SetStatusCode(fasthttp.StatusOK)
        ctx.Write(jsonBytes)
    } else {
        ctx.SetStatusCode(fasthttp.StatusInternalServerError)
        ctx.Write([]byte(`{"error":"failed to encode JSON"}`))
    }
}
