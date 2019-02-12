workflow "Post Message" {
  on = "push"
  resolves = "Post to #general"
}

action "Post to #general" {
  uses = "./../../actions/post-message"
  args = "User $GITHUB_ACTOR says hello."
  secrets = ["WEBHOOK_URL"]
}
