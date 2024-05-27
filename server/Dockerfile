FROM rust:slim-bookworm

COPY Cargo.lock Cargo.lock
COPY Cargo.toml Cargo.toml
COPY src src

RUN apt update && \
    apt install -y python3-dev
RUN cargo build --release

CMD ["./target/release/twocents-server"]
