workflow "Post Message" {
  on = "push"
  resolves = "Post to #general"
}

action "Post to #general" {
  uses = "./../../actions/post-message"
  args = "User $GITHUB_ACTOR says hello."
  env = {
    WORKFLOW_COMMS_URL = "https://my-workflow-app.example.com"
    MESSAGE_PROVIDER = "slack"
    SLACK_CHANNEL_ID = "CCY4A8EKY"
  }
}
