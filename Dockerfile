FROM alpine

RUN apk add --no-cache bash openssl

RUN mkdir /app
WORKDIR /app

ADD _build/prod/rel/slack_actions_umbrella/releases/*/slack_actions_umbrella.tar.gz .

ENV MIX_ENV=prod

CMD ./bin/slack_actions_umbrella foreground
