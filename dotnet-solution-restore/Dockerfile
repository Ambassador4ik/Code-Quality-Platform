FROM ubuntu:22.04

RUN apt-get update && apt-get install -y wget unzip \
    && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y dotnet-sdk-7.0 aspnetcore-runtime-7.0

ADD build.sh .

CMD ["bash", "build.sh"]
