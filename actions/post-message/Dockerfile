FROM debian

LABEL "repository"="https://github.com/jclem/slack_actions"
LABEL "homepage"="https://github.com/jclem/slack_actions/tree/master/post-message"
LABEL "maintainer"="Jonathan Clem <jonathan@jclem.net>"

LABEL "com.github.actions.name"="Post Message"
LABEL "com.github.actions.description"="An action for posting a message to a Slack channel"
LABEL "com.github.actions.icon"="message-circle"
LABEL "com.github.actions.color"="blue"

RUN apt-get update
RUN apt-get install -y curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
