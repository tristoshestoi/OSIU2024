FROM ubuntu:latest

RUN apt-get update && apt-get install -y python3


RUN apt-get install -y python3-pip
RUN apt-get install -y git

COPY . /app
WORKDIR /app

CMD ["python3", "app.py"]
