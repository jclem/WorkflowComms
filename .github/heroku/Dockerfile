FROM docker

RUN apk add --update nodejs nodejs-npm
RUN npm install --global heroku

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
