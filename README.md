# WorkflowCommms

WorkflowCommms provides an interface between GitHub Actions and any messaging
platform.

## Overview

WorkflowComms works by acting as a proxy between GitHub Actions and a messaging
provider.

For example, if you want to pause in the middle of a deployment workflow and
have an administrator manually confirm that they want the deployment to go
ahead, WorkflowComms can handle proxying that confirmation back and forth
between your running action and, for example, Slack or Twilio.

Likewise, if you simply want to send a message to a messaging provider,
WorkflowComms can do this, as well (although that's usually also possible
_without_ WorkflowComms using just _curl_ in an action).
