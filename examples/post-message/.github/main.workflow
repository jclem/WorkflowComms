workflow "Post Message" {
  on = "push"
  resolves = "Post to #general"
}

action "Post to #general" {
  uses = "./../../actions/post-message"
  args = "Hello, world."
  secrets = ["WEBHOOK_URL"]
}
