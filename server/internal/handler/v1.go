package handler

import "github.com/valyala/fasthttp"

// HomeHandler handles the root path
func V1Handler(ctx *fasthttp.RequestCtx) {
	ctx.Redirect("https://www.youtube.com/watch?v=dQw4w9WgXcQ",fasthttp.StatusFound)
}
