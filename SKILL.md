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
2. Convert the request into structured `rr host plan-add` and `rr host add` commands.
3. Never pass raw natural language to `rr`.
4. Never store passwords, tokens, or private keys.
5. If the user provides a password, state that it will not be saved and use terminal SSH key bootstrap instead.
6. Write server connection details only to local SSH config, and write remote-runtime inventory with `ssh_alias` only.

Example mapping:

User says: `IP:<address> user:<ssh-user> password:*** 帮我配置成本地测试环境`

Codex should infer:

- env: `test`
- host name: `lan-home-local-test-01`
- ssh alias: `lan-home-local-test-01`
- host address: the provided address, used only in local SSH config
- user: the provided SSH user
- role: `test`

Then run:

```bash
bash ~/.agents/skills/remote-runtime/scripts/rr host plan-add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host <address> --user <user> --role test --provider home --location local
bash ~/.agents/skills/remote-runtime/scripts/rr host add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host <address> --user <user> --role test --provider home --location local
```

Never expose:

- IP addresses
- private keys
- passwords
- tokens
- secret env vars
