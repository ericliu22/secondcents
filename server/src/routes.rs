use axum::{
    routing::get,
    Router
};

use crate::handle_get;

/**
A function that returns a `Router` instance

Contains all the routes that we handle using either `handle_get` or `handle_post`
 */
pub fn get_routes() -> Router {
    Router::new()
        .route("/", get(handle_get::homepage))
        .route("/foo",get(handle_get::foo))
        .route("/python",get(handle_get::python))
        .fallback(handle_get::fallback)
}
