# Onboarding Hosts

Use Codex reasoning for natural language. Use `rr` only for structured execution.

## Flow

1. Extract intent, environment, address, SSH user, role, provider, location, and service hints.
2. Generate a host name with `<scope>-<provider>-<location>-<role>-<index>`.
3. Run `rr host plan-add` and show the plan.
4. Run `rr host add` only after the user confirms or explicitly asks to proceed.
5. Run `rr host validate <host>` and `rr ssh doctor <host>`.

## Commands

```bash
bash ~/.agents/skills/remote-runtime/scripts/rr host plan-add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host 192.0.2.151 --user appuser --role test --provider home --location local
bash ~/.agents/skills/remote-runtime/scripts/rr host add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host 192.0.2.151 --user appuser --role test --provider home --location local
```

## Security

- Do not save passwords.
- Do not write IP addresses to repository default configs.
- Write addresses only to the user's local SSH config.
- Write remote-runtime inventory with `ssh_alias` only.
- If a password is provided, use it only through terminal SSH prompts such as `ssh-copy-id`.
