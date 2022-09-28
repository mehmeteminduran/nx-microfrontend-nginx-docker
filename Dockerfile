# Stage 1: Compile and Build app
FROM node:16.17.0-alpine as builder
WORKDIR /angular-app
# Minimizing cache busting and rebuilds
COPY package.json .
# Install some dependencies
RUN npm config -g set legacy-peer-deps true
RUN npm install
RUN npm i -g nx@14.6.5
# Copy current working directory files inside the container
COPY . .
# Generate the build of the application
RUN npm run build

# Stage 2: Serve app with nginx server
FROM nginx
COPY ./nginx.conf /etc/nginx/nginx.conf
# Set working directory to nginx asset directory
WORKDIR /usr/share/nginx/html
# Remove default nginx static assets
RUN rm -rf ./*
COPY --from=builder /angular-app/dist .
# Exposing a port, here it means that inside the container
# the app will be using Port 4200 while running
EXPOSE 4200
# Containers run nginx with global directives and daemon off
CMD ["nginx", "-g", "daemon off;"]
# docker build -f Dockerfile -t angularapp .
# run with port mapping (any incoming traffic on local network port 8080 forwarded  4200 inside the container )
# docker run -d -p 8080:4200 iangularapp
# export and import docker file
# docker save angularapp:latest | gzip > angularapp.tar.gz
# docker load < angularapp.tar.gz
