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
- add or onboard server resources from natural language

Always use the `rr` command as the single entry point.

If `rr` is not directly available, first run or suggest `./install.sh --with-cli`, then verify with:

```bash
rr doctor cli
rr version
```

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

Natural language server onboarding:

1. Use Codex reasoning to extract the user's intent and fields.
2. Convert the request into structured `rr host onboard-plan` and `rr host onboard-apply` commands.
3. Never pass raw natural language to `rr`.
4. Never store passwords, tokens, or private keys.
5. If the user provides a password, state that it will not be saved and use terminal SSH key bootstrap instead.
6. Write server connection details only to local SSH config, and write remote-runtime inventory with `ssh_alias` only.
7. Use `rr config explain` when the user asks where resources are stored or when scope is ambiguous.
For details, read `references/onboarding-hosts.md`.

Docker demo workflow:

1. Start with `rr demo docker plan <target>`.
2. For real changes, require confirmation and run `rr demo docker deploy <target> --yes`.
3. Verify with `rr demo docker status <target>` and `rr demo docker health <target>`.
4. Clean up with `rr demo docker cleanup <target> --yes`.
5. If ports conflict, use `rr port find <target> --from <port> --to <port>`.

Never expose:

- IP addresses
- private keys
- passwords
- tokens
- secret env vars
