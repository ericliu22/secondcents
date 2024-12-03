package handler

import (
	"github.com/valyala/fasthttp"
)

// HomeHandler handles the root path
func HomeHandler(ctx *fasthttp.RequestCtx) {
	ctx.SendFile("../static/index.html")
}

// HomeHandler handles the root path
func VersionOneHandler(ctx *fasthttp.RequestCtx) {
	ctx.Redirect("https://www.youtube.com/watch?v=dQw4w9WgXcQ",fasthttp.StatusFound)
}
