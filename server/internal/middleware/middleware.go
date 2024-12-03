package middleware

import (
	"github.com/valyala/fasthttp"
)

type Middleware func(next fasthttp.RequestHandler) fasthttp.RequestHandler

func ChainMiddleware(finalHandler fasthttp.RequestHandler, middlewares ...Middleware) fasthttp.RequestHandler {
	// Wrap the final handler with the middleware chain
	for i := len(middlewares) - 1; i >= 0; i-- {
		finalHandler = middlewares[i](finalHandler)
	}
	return finalHandler
}
