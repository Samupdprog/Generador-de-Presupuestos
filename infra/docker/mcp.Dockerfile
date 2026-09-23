FROM node:22-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install

RUN npm run build --workspace @quotes/mcp

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder --chown=node:node /app/apps/mcp/dist ./dist
USER node
EXPOSE 4001
CMD ["node", "dist/index.mjs"]
