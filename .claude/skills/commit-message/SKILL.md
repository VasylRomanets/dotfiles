---
name: commit-message
description: Propose a commit message in my style for the currently staged changes. Only run when the user types /commit-message.
disable-model-invocation: true
---

1. Run `git diff --staged`. If nothing is staged, say so and stop. Never stage files and never run `git commit`.
2. Run `git log -10 --format=%s` to match the wording of recent commits.
3. If the staged changes cover unrelated things, suggest how to split them into separate commits and stop. If the user replies "one", carry on with a single commit.
4. Propose a message:
   - use the imperative mood in the subject line
   - capitalize the subject line
   - do not end the subject line with a period
   - no type or scope prefix, like `feat:` or `fix(zsh):`
   - limit the subject line to 50 characters or less
   - skip the body when the subject says it all
   - otherwise separate subject from body with a blank line
   - use the body to explain what and why vs. how
   - wrap the body at 72 characters
   - no co-author or any other attribution
5. Print the message in a code block, then copy exactly that text to the clipboard with `pbcopy`.
