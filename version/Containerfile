# Pull base image
FROM python:3.7-alpine
####
MAINTAINER "moaz.refat@hotmail.com"
COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]