workflow "Confirm a Choice" {
  on = "push"
  resolves = "Deploy"
}

action "Confirm" {
  uses = "./../../actions/confirm"
  args = "Do you want to deploy?"
  secrets = ["SLACK_BOT_TOKEN"]
  env = {
    SLACK_ACTIONS_URL = "https://my-slack-app.example.com"
    SLACK_BOT_CHANNEL = "CCY4A8EKY"
  }
}

action "Deploy" {
  uses = "docker://alpine"
  needs = "Confirm"
  args = "echo Deployed!"
}
