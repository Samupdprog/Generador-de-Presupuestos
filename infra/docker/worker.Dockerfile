FROM node:22-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci

RUN npm run build --workspace @quotes/worker

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder --chown=node:node /app/apps/worker/dist ./dist
USER node
EXPOSE 4002
CMD ["node", "dist/index.mjs"]
