FROM node:22-alpine AS builder
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@10.17.1 --activate
WORKDIR /app
COPY . .
RUN pnpm install --no-frozen-lockfile

RUN pnpm --filter @quotes/worker build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder --chown=node:node /app/apps/worker/dist ./dist
USER node
EXPOSE 4002
CMD ["node", "dist/index.mjs"]
