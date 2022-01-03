## Pull base image
#FROM python:3.7
FROM python:3.7-alpine3.7

MAINTAINER "moaz.refat@hotmail.com"
COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt --no-cache-dir
ENTRYPOINT ["python"]
CMD ["app.py"]
