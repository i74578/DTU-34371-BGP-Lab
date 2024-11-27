FROM openbgpd/openbgpd:8.3

RUN apk add --no-cache python3 scapy
RUN mkdir /attack-scripts
ENV PATH="/attack-scripts:${PATH}"
