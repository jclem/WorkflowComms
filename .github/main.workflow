workflow "On Push" {
  on = "push"
  resolves = ["Post Success Message"]
}

workflow "On Dispatch" {
  on = "repository_dispatch"
  resolves = ["Post Success Message"]
}

action "Filter Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Get Dependencies" {
  uses = "./.github/mix"
  args = "deps.get"
  env = {
    MIX_ENV = "dev"
  }
}

action "Run Tests" {
  uses = "./.github/mix"
  needs = "Get Dependencies"
  args = "test"
  env = {
    MIX_ENV = "test"
  }
}

action "Check Formatting" {
  uses = "./.github/mix"
  needs = "Get Dependencies"
  args = "format --check-formatted"
  env = {
    MIX_ENV = "dev"
  }
}

action "Create Release" {
  uses = "./.github/mix"
  needs = ["Run Tests", "Check Formatting", "Filter Master"]
  args = "do deps.get, compile, release"
  secrets = ["COOKIE"]
}

action "Registry Login" {
  uses = "./.github/heroku"
  needs = "Filter Master"
  args = "container:login"
  secrets = ["HEROKU_API_KEY"]
}

action "Confirm Deploy" {
  uses = "./actions/confirm"
  needs = "Filter Master"
  args = "User $GITHUB_ACTOR wants to deploy workflow_comms. Do you wish to continue?"
  secrets = ["SLACK_BOT_TOKEN"]
  env = {
    workflow_comms_URL = "https://nameless-basin-14691.herokuapp.com"
    SLACK_BOT_CHANNEL = "CCY4A8EKY"
  }
}

action "Container Push" {
  uses = "./.github/heroku"
  needs = [
    "Create Release",
    "Registry Login",
    "Confirm Deploy",
  ]
  args = "container:push web --app $HEROKU_APP_NAME"
  secrets = ["HEROKU_API_KEY", "HEROKU_APP_NAME"]
}

action "Container Release" {
  uses = "./.github/heroku"
  needs = "Container Push"
  args = "container:release web --app $HEROKU_APP_NAME"
  secrets = ["HEROKU_API_KEY", "HEROKU_APP_NAME"]
}

action "Post Success Message" {
  uses = "./actions/post-message"
  needs = ["Container Release"]
  secrets = ["WEBHOOK_URL"]
  args = "\"workflow_comms\" has been deployed by $GITHUB_ACTOR"
}
