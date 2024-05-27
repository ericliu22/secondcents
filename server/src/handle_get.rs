use axum::{
    response::Response,
    body::Body,
    http::StatusCode
};

use crate::call_python;

pub async fn homepage() -> Response {
    Response::builder()
        .status(StatusCode::OK)
        .header("Access-Control-Allow-Origin", "https://localhost:19006")
        .body(Body::from("HELLO FROM RUST BACKEND"))
        .unwrap()
}

pub async fn foo() -> Response {
    Response::builder()
        .status(StatusCode::OK)
        .header("Access-Control-Allow-Origin", "https://localhost:19006")
        .body(Body::from("HELLO FROM FOO"))
        .unwrap()
}

pub async fn python() -> Response {
    match call_python::python_string("/src/bots/backend_test.py","testString") {
        Ok(result) => {
            Response::builder()
                .status(StatusCode::OK)
                .header("Access-Control-Allow-Origin", "https://localhost:19006")
                .body(Body::from(format!("PYTHON BACKEND: {result}")))
                .unwrap()
        },
        Err(err) => {
            Response::builder()
                .status(StatusCode::OK)
                .header("Access-Control-Allow-Origin", "https://localhost:19006")
                .body(Body::from(format!("PYTHON BACKEND: Failed to run python function {err}")))
                .unwrap()
        }
    }
}

pub async fn fallback() -> Response {
    Response::builder()
        .status(StatusCode::NOT_FOUND)
        .body(Body::from("Fuck you file not found"))
        .unwrap()
}
