FROM node:19-alpine3.15 as dev-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --frozen-lockfile

FROM node:19-alpine3.15 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
# copy all except the dockerignore content
COPY . .
# RUN yarn build
RUN yarn build

FROM nginx:1.25.3-alpine3.18-slim as prod
COPY --from=builder /app/dist /usr/share/nginx/html
# the next line copy the 'assets' folder to the nginx folder to be able to access the images
COPY assets/ /usr/share/nginx/html/assets
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
EXPOSE 80
# Comando para iniciar el servidor nginx en segundo plano
CMD ["nginx", "-g", "daemon off;"]