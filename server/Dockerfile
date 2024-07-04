FROM oven/bun:debian

COPY package.json ./
COPY bun.lockb ./
COPY src ./

EXPOSE 8080
RUN bun install
CMD bun --bun run index.ts
