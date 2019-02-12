workflow "Build & Release" {
  on = "repository_dispatch"
  resolves = "Container Release"
}

action "Filter Master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Create Release" {
  uses = "./.github/mix"
  needs = "Filter Master"
  args = "do deps.get, compile, release"
  secrets = ["COOKIE"]
}

action "Registry Login" {
  uses = "./.github/heroku"
  needs = "Create Release"
  args = "container:login"
  secrets = ["HEROKU_API_KEY"]
}

action "Container Push" {
  uses = "./.github/heroku"
  needs = "Registry Login"
  args = "container:push web --app $HEROKU_APP_NAME"
  secrets = ["HEROKU_API_KEY", "HEROKU_APP_NAME"]
}

action "Container Release" {
  uses = "./.github/heroku"
  needs = "Container Push"
  args = "container:release web --app $HEROKU_APP_NAME"
  secrets = ["HEROKU_API_KEY", "HEROKU_APP_NAME"]
}
