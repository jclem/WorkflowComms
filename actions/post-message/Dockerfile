FROM ruby:slim

LABEL "repository"="https://github.com/jclem/workflow_comms"
LABEL "homepage"="https://github.com/jclem/workflow_comms/tree/master/post-message"
LABEL "maintainer"="Jonathan Clem <jonathan@jclem.net>"

LABEL "com.github.actions.name"="Post Message"
LABEL "com.github.actions.description"="An action for posting a message to a Slack channel"
LABEL "com.github.actions.icon"="message-circle"
LABEL "com.github.actions.color"="blue"

COPY entrypoint.sh /entrypoint.sh
COPY script.rb /script.rb

ENTRYPOINT ["/entrypoint.sh"]
