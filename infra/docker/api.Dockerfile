FROM node:22-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci

RUN npm run build --workspace @quotes/api

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder --chown=node:node /app/apps/api/dist ./dist
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
USER node
EXPOSE 4000
CMD ["node", "dist/index.mjs"]
