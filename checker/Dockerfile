FROM ubuntu:22.04

RUN apt-get update && apt-get upgrade -y

COPY check.sh checker ./

CMD ["bash", "check.sh"]