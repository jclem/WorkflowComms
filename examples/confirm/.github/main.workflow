workflow "Confirm a Choice" {
  on = "push"
  resolves = "Deploy"
}

action "Confirm Twilio" {
  uses = "./../../actions/confirm"
  args = "User $GITHUB_ACTOR wants to deploy. Do you wish to continue?"
  env = {
    WORKFLOW_COMMS_URL = "https://my-workflow-app.example.com"
    MESSAGE_PROVIDER = "twilio"
    TWILIO_WORKFLOW_URL = "https://studio.twilio.com/v1/Flows/--example--/Executions"
    TWILIO_TO = "+15555555555"
    TWILIO_FROM = "+15555555555"
  }
}

action "Confirm Slack" {
  uses = "./../../actions/confirm"
  args = "User $GITHUB_ACTOR wants to deploy. Do you wish to continue?"
  env = {
    WORKFLOW_COMMS_URL = "https://my-workflow-app.example.com"
    MESSAGE_PROVIDER = "slack"
    SLACK_CHANNEL_ID = "CCY4A8EKY"
  }
}

action "Deploy" {
  uses = "docker://alpine"
  needs = "Confirm Twilio"
  args = "echo Deployed!"
}
