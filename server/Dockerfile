FROM nginx:alpine
RUN apk update
RUN apk add --no-cache nginx

COPY ./server/index.html /usr/share/nginx/html/
COPY ./server/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
