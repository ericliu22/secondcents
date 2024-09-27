package handler

import "github.com/valyala/fasthttp"

// HomeHandler handles the root path
func HomeHandler(ctx *fasthttp.RequestCtx) {
    ctx.WriteString("TwoCents API Website")
}
