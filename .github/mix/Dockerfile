FROM elixir:alpine

ENV MIX_HOME=/.mix
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV

RUN mix local.rebar --force
RUN mix local.hex --force

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
