package middleware

import (
	"context"
	"time"

	"github.com/valyala/fasthttp"
)


func WithRequestContext(next fasthttp.RequestHandler) fasthttp.RequestHandler {
	return func(ctx *fasthttp.RequestCtx) {
		// Create a context with timeout
		c, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Store the context in fasthttp.RequestCtx
		ctx.SetUserValue("ctx", c)

		// Call the next handler
		next(ctx)
	}
}

func GetRequestContext(ctx *fasthttp.RequestCtx) context.Context {
	if c, ok := ctx.UserValue("ctx").(context.Context); ok {
		return c
	}
	return context.Background() // Fallback to default context
}
