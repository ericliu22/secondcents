FROM oven/bun:debian

COPY package.json ./
COPY bun.lockb ./
COPY src ./
COPY .env ./

RUN bun install
CMD bun --bun run index.ts
