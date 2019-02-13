FROM alpine

RUN apk add --no-cache bash openssl

RUN mkdir /app
WORKDIR /app

ADD _build/prod/rel/workflow_comms/releases/*/workflow_comms.tar.gz .

ENV MIX_ENV=prod

CMD ./bin/workflow_comms foreground
