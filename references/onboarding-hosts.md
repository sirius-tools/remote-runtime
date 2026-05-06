# Onboarding Hosts

Use Codex reasoning for natural language. Use `rr` only for structured execution.

## Flow

1. Extract intent, environment, address, SSH user, role, provider, location, and service hints.
2. Generate a host name with `<scope>-<provider>-<location>-<role>-<index>`.
3. Run `rr config explain` if scope is unclear.
4. Run `rr host onboard-plan` and show the plan.
5. Run `rr host onboard-apply --yes --from-plan <plan-file>` only after the user confirms or explicitly asks to proceed.
6. Let apply run `rr validate`, `rr host validate <host>`, and `rr ssh doctor <host>`.

## Commands

```bash
rr host onboard-plan --env test --address <private-host-or-ip> --user <ssh-user> --role app --provider home --location local --scope project
rr host onboard-apply --yes --from-plan ~/.remote-runtime/plans/onboard-<generated-host>.yaml
```

## Security

- Do not save passwords.
- Do not write IP addresses to repository default configs.
- Write addresses only to the user's local SSH config.
- Write remote-runtime inventory with `ssh_alias` only.
- If a password is provided, use it only through terminal SSH prompts such as `ssh-copy-id`.
