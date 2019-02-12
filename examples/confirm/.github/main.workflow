workflow "Confirm a Choice" {
  on = "push"
  resolves = "Deploy"
}

action "Confirm" {
  uses = "./../../actions/confirm"
  args = "User $GITHUB_ACTOR wants to deploy. Do you wish to continue?"
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
