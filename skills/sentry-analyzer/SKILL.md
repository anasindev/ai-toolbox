---
name: sentry-analyzer
description: Fetch a Sentry issue, find its root cause and propose 3 robust and clean ways to fix it. Use when the user runs /sentry-analyzer <ISSUE-ID or URL>.
disable-model-invocation: true
---

Using the Sentry MCP, fetch the issue `$ARGUMENTS`, analyze the root cause and propose 3 robust and clean ways to fix it.

Do NOT use the Sentry `analyze_issue_with_seer` tool.
