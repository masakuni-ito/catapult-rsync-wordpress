FROM debian:8.10-slim

RUN apt-get update 
RUN apt-get install -y rsync openssh-client
