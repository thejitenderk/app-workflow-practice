FROM node:20.16.0-slim AS build
WORKDIR /app

# Dependencies pehle copy karo (layer caching ke liye)
COPY package*.json ./
RUN npm ci

# Baaki code copy karo
COPY . .
RUN npm run build

# ---- Production Stage ----
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Purana default content remove karo
RUN rm -rf ./*

COPY --from=build /app/build .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]