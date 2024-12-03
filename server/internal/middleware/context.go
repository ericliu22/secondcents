package middleware

import (
	"context"
	"time"

	"github.com/valyala/fasthttp"
)

func WithRequestContext() Middleware {
	return func(next fasthttp.RequestHandler) fasthttp.RequestHandler {
		return func(ctx *fasthttp.RequestCtx) {
			c, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()

			ctx.SetUserValue("ctx", c)
			next(ctx)
		}
	}
}

func GetRequestContext(ctx *fasthttp.RequestCtx) context.Context {
	if c, ok := ctx.UserValue("ctx").(context.Context); ok {
		return c
	}
	return context.Background() // Fallback to default context
}
