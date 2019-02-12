FROM elixir:alpine

ENV MIX_HOME=/.mix
ENV MIX_ENV=prod

RUN mix local.rebar --force
RUN mix local.hex --force

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
