---
name: remote-runtime
description: Use this skill when the user asks Codex to deploy to remote servers, test on cloud or LAN hosts, inspect logs, check health, restart services, run smoke tests, execute remote diagnostics, compare environments, or manage remote runtime workflows using SSH aliases.
---

# Remote Runtime Skill

Use this skill when the user asks to:

- deploy to a server
- test on a cloud host
- test on an internal LAN host
- check remote service health
- inspect remote logs
- restart a remote service
- run smoke tests
- run remote diagnostics
- compare cloud and LAN environments
- operate a configured remote runtime environment

Always use the `rr` command as the single entry point.

Before executing:

1. Read relevant config.
2. Resolve target.
3. Validate policy.
4. Show or generate execution plan for risky actions.
5. Execute using SSH alias only.
6. Summarize result.
7. On failure, collect diagnostics.

Codex workflow:

1. 识别用户意图。
2. 读取配置。
3. 解析目标。
4. 高风险操作先 plan。
5. 使用 rr 命令执行。
6. 总结结果。
7. 失败时给出诊断建议。

Never expose:

- IP addresses
- private keys
- passwords
- tokens
- secret env vars
