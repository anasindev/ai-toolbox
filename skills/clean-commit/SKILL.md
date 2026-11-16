---
name: clean-commit
description: Clean up the work of the current development cycle (debug logs, stray files, debug statements), document a genuinely surprising solution if there is one, then commit. Use when the user runs /clean-commit [extra instructions].
disable-model-invocation: true
---

# Clean commit

1. Remove the logs, unnecessary files and debug statements added during this development cycle. Touch only what this cycle added.
2. If we had a deep discussion and implemented a truly surprising solution, add a small `.md` file in the `docs/` directory explaining it. Only when it is genuinely needed for a future reader to understand the project.
3. Apply the user's extra instructions, if any: `$ARGUMENTS`
4. If there are none, commit.
