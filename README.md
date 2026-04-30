# remote-runtime

remote-runtime 是一个团队级可复用的 Codex Skill，用于通过 SSH alias 安全管理多环境、多主机远程运行时流程，覆盖部署、回滚、健康检查、日志、诊断与对比。

## 场景
- 部署到云主机或内网主机
- 远程健康检查与日志查看
- 远程诊断与环境对比
- 配置驱动的任务编排

## 安装（推荐，Smithery 标准方式）
```bash
npx @smithery/cli@latest skill add sirius-tools/remote-runtime
```

说明：
- 这是 smithery.ai 上主流 skill 安装方式，由 Smithery CLI 负责安装到本地技能目录。
- 安装后请刷新/重启 Codex 会话，让 Skill 重新发现。

## 安装（本地开发/离线兜底）
```bash
cd remote-runtime
./install.sh
```

说明：
- `./install.sh`：默认安装到 `~/.codex/skills/remote-runtime`。
- `./install.sh --with-cli`：额外创建 `~/.local/bin/rr`。

## 快速开始
```bash
~/.codex/skills/remote-runtime/scripts/rr doctor
~/.codex/skills/remote-runtime/scripts/rr init --non-interactive \
  --service-name myapp \
  --deploy-method jar-systemd \
  --cloud-alias jdcloud \
  --lan-alias intranet \
  --health-url http://127.0.0.1:8080/actuator/health \
  --workdir /opt/apps/myapp
~/.codex/skills/remote-runtime/scripts/rr validate
~/.codex/skills/remote-runtime/scripts/rr list hosts
~/.codex/skills/remote-runtime/scripts/rr health env:test --dry-run
```

## 初始化项目
- 交互：`rr init`
- 非交互：见上方命令

## 主机命名规范
`<scope>-<provider_or_site>-<region_or_location>-<role>-<index>`

## 配置说明
- `config/inventory.yaml`: 主机与 vars
- `config/environments.yaml`: 环境分组
- `config/tasks.yaml`: 任务编排
- `config/policies.yaml`: 安全策略
- `config/runtime.yaml`: 运行时参数

## 常用命令
```bash
rr list hosts
rr list envs
rr list tasks
rr plan deploy env:test
rr status env:all --dry-run
rr run diagnose env:all --dry-run
```

## Spring Boot jar 示例
参见 `examples/springboot-jar/`。

## Docker Compose 示例
参见 `examples/docker-compose/`。

## 新增主机
编辑 `inventory.yaml`，仅填写 `ssh_alias`，不要填写 IP。

## 新增环境
编辑 `environments.yaml` 的 `environments.<name>`。

## 新增任务
编辑 `tasks.yaml` 增加 `tasks.<name>.steps`。

## 新增 action
在 `scripts/actions/` 新增 `<name>.sh`，并在 `scripts/rr` 注册。

## 安全策略
- 禁止裸 IP
- 高风险动作需要确认
- 输出脱敏

## 审计日志
`~/.remote-runtime/audit/YYYY-MM-DD.log`

## 故障排查
优先执行：`rr doctor`、`rr validate`、`rr plan <action> <target>`。

## FAQ
- Q: 无服务器如何验证？
  A: 使用 `--dry-run`。
- Q: 为什么 `rr` 命令找不到？
  A: 先用 `~/.codex/skills/remote-runtime/scripts/rr`，或执行 `./install.sh --with-cli` 并确保 `~/.local/bin` 在 PATH。
