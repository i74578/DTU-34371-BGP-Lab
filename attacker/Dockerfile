FROM openbgpd/openbgpd:8.3
RUN apk update
RUN apk add --no-cache iptables nginx

COPY ./scripts/http-attack /usr/local/bin/http-attack
RUN chmod +x /usr/local/bin/http-attack
COPY ./scripts/restore /usr/local/bin/restore
RUN chmod +x /usr/local/bin/restore

COPY ./attacker/index.html /usr/share/nginx/html/
COPY ./attacker/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
