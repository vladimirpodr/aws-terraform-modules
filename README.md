# aws-terraform-modules

# Git merge rules

* Only `fast-forward-only` merge mode is supported.

* Only single commit per story/task. So your SINGLE commit in the feature branch HAS TO be always on top of current master HEAD.

* Your commit message has to follow [Semantic Commit Message rules](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716).

Sample artificial git commit:

```bash
git commit -a -m 'feat: add support to phase of the moon'
```