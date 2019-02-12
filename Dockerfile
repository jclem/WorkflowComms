FROM alpine

RUN apk add --no-cache bash openssl

RUN mkdir /app
WORKDIR /app

ADD _build/prod/rel/slack_actions/releases/*/slack_actions.tar.gz .

ENV MIX_ENV=prod

CMD ./bin/slack_actions foreground
