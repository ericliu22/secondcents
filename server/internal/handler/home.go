package handler

import (
	"github.com/valyala/fasthttp"
	"log"
	"path/filepath"
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
