FROM node:22-alpine

WORKDIR /app
COPY . .
RUN npm ci

CMD ["npm", "run", "db:mi"]