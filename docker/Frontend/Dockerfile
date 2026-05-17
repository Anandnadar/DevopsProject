# FROM node:alpine
# WORKDIR /src
# COPY package.json package.json
# COPY package.-lock.json package-lock.json
# RUN npm install
# COPY . . /src/

# # Expose Vite default port
# EXPOSE 5173

# # Start Vite dev server
# CMD ["npm", "run", "dev", "--", "--host"]

# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN npm run build

# Production Stage
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]