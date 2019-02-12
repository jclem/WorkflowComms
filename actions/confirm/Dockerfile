FROM ruby:slim

LABEL "repository"="https://github.com/jclem/slack_actions"
LABEL "homepage"="https://github.com/jclem/slack_actions/tree/master/post-message"
LABEL "maintainer"="Jonathan Clem <jonathan@jclem.net>"

LABEL "com.github.actions.name"="Confirm via Slack"
LABEL "com.github.actions.description"="An action for confirming continuation of a workflow"
LABEL "com.github.actions.icon"="help-circle"
LABEL "com.github.actions.color"="blue"

COPY entrypoint.sh /entrypoint.sh
COPY script.rb /script.rb

ENTRYPOINT ["/entrypoint.sh"]
