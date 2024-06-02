# Server

The server should be run within a docker container.

1. Create the image:
```bash
./buildDocker.sh
```
2. Run the server:
```bash
./runDocker.sh
```

Optionally you can get server output by doing
```bash
./runDocker.sh debug
```

# Bun

To install dependencies:

```bash
bun install
```

To run:

```bash
bun run src/index.ts
```

