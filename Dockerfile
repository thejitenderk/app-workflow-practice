# FROM node:20.16.0-slim AS build
# WORKDIR /app

# # Dependencies pehle copy karo (layer caching ke liye)
# COPY package*.json ./
# RUN npm ci

# # Baaki code copy karo
# COPY . .
# RUN npm run build

# # ---- Production Stage ----
# FROM nginx:stable-alpine
# WORKDIR /usr/share/nginx/html

# # Purana default content remove karo
# RUN rm -rf ./*

# COPY --from=build /app/build .

# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]


FROM node:latest AS build

WORKDIR /app

# BAD PRACTICE 2: package.json aur code ek saath copy (no layer caching)
COPY . .
RUN npm install          # BAD PRACTICE 3: npm ci ki jagah npm install

RUN npm run build

# BAD PRACTICE 4: latest tag nginx bhi
FROM nginx:latest

# BAD PRACTICE 5: WORKDIR nahi set kiya
# BAD PRACTICE 6: rm -rf nahi kiya purana content

COPY --from=build /app/build /usr/share/nginx/html

# BAD PRACTICE 7: EXPOSE nahi likha
# BAD PRACTICE 8: CMD me shell form use kiya (exec form better hota hai)
CMD nginx -g "daemon off;"