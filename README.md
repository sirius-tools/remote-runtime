# remote-runtime

remote-runtime 是一个面向 Codex 的远程运行时编排 Skill，用于通过 SSH alias 安全执行多环境部署、诊断、健康检查、日志与回滚。

## 安装（Smithery 页面优先）
在 `https://smithery.ai/skills/sirius-tools/remote-runtime` 页面：
1. 在 `or add to your agent` 先选择 `Codex`。
2. 复制页面生成的安装命令执行。

推荐命令（Codex）：
```bash
npx @smithery/cli@latest skill add sirius-tools/remote-runtime -a codex -g
```

安装后刷新/重启 Codex 会话，让技能重新发现。

## 本地开发安装（兜底）
```bash
./install.sh
```

- 默认安装到 `~/.agents/skills/remote-runtime`
- 可选 `./install.sh --with-cli` 创建 `~/.local/bin/rr`

## 快速开始
```bash
bash ~/.agents/skills/remote-runtime/scripts/rr doctor
bash ~/.agents/skills/remote-runtime/scripts/rr init --non-interactive \
  --service-name myapp \
  --deploy-method jar-systemd \
  --cloud-alias jdcloud \
  --lan-alias intranet \
  --health-url http://127.0.0.1:8080/actuator/health \
  --workdir /opt/apps/myapp
bash ~/.agents/skills/remote-runtime/scripts/rr validate
bash ~/.agents/skills/remote-runtime/scripts/rr health env:test --dry-run
```

## 适用场景
- 部署到云主机或内网主机
- 远程健康检查与日志查看
- 远程诊断与环境对比
- 配置驱动任务编排
- 用自然语言让 Codex 添加服务器资源，并交给本 Skill 结构化管理

## 配置结构
- `config/inventory.yaml`
- `config/environments.yaml`
- `config/tasks.yaml`
- `config/policies.yaml`
- `config/runtime.yaml`

## 常用命令
```bash
rr list hosts
rr list envs
rr list tasks
rr host plan-add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host 192.0.2.151 --user appuser
rr host add --env test --name lan-home-local-test-01 --ssh-alias lan-home-local-test-01 --host 192.0.2.151 --user appuser
rr plan deploy env:test
rr status env:all --dry-run
rr run diagnose env:all --dry-run
```

自然语言接入服务器时，由 Codex 从用户描述中提取环境、主机用途、SSH 用户和地址，然后调用结构化的 `rr host plan-add` / `rr host add`。`rr` 不解析自然语言，也不会保存密码。

## Codex 使用场景示例

### 1. 查看我有哪些服务器资源
你可以直接对 Codex 说：

> 帮我看下 remote-runtime 里现在有哪些服务器资源。

Codex 应执行：
```bash
rr host list
rr list envs
rr status env:all --dry-run
```

期望结果：
- `rr host list` 展示已登记的主机资源、环境、角色和 SSH alias
- `rr list envs` 展示 `test` / `prod` / `lan` 等环境分组
- `--dry-run` 只展示将要执行的远程命令，不连接或修改服务器

### 2. 用自然语言添加本地测试服务器
你可以直接对 Codex 说：

> IP：192.0.2.151 user：appuser password：示例密码，帮我配置成本地测试环境。

Codex 应按这个流程处理：
```bash
rr host plan-add \
  --env test \
  --name lan-local-test-01 \
  --ssh-alias lan-local-test-01 \
  --host 192.0.2.151 \
  --user appuser
```

确认计划后再执行：
```bash
rr host add \
  --env test \
  --name lan-local-test-01 \
  --ssh-alias lan-local-test-01 \
  --host 192.0.2.151 \
  --user appuser
```

重要边界：
- 密码只用于当前终端内的 SSH 首次引导或用户手动配置，不写入仓库、不写入 Skill 配置。
- Skill 配置只保存 `ssh_alias`、环境、角色、健康检查 URL、部署目录等非敏感运行时元数据。
- 真实 IP、账号等如果属于私有资产，应放在本地 ignored overlay，不提交到公开仓库。

### 3. 配置后检查服务器是否可用
你可以说：

> 检查刚才添加的本地测试环境是否能连接，顺便看下健康检查命令。

Codex 应执行：
```bash
rr validate
rr doctor
rr health env:test --dry-run
```

如果需要真实连接，应由你明确授权后再执行：
```bash
rr health env:test
```

### 4. 部署前预演
你可以说：

> 帮我预演部署 test 环境，不要真的改服务器。

Codex 应执行：
```bash
rr deploy env:test --dry-run
```

预演会展示 build、package、backup、upload、switch release、restart、health 等步骤对应的本地或远程命令，但不会写入远程服务器。

### 5. 真实部署
你可以说：

> 确认部署 test 环境。

Codex 应执行：
```bash
rr deploy env:test --yes
```

高风险动作默认需要 `--yes`。如果目标是受保护环境，例如 `prod`，还需要额外显式授权：
```bash
RR_CONFIRM_PROTECTED=true rr deploy env:prod --yes
```

### 6. 诊断线上问题
你可以说：

> 帮我诊断 test 环境为什么访问不了，先不要改服务器。

Codex 应执行：
```bash
rr diagnose env:test --dry-run --report
rr logs env:test --dry-run
rr port-check env:test --dry-run
rr db-check env:test --dry-run
```

如果 dry-run 展示的命令符合预期，再由你授权执行真实诊断。

### 7. 回滚
你可以说：

> test 环境刚才发版有问题，帮我回滚。

Codex 应先预演：
```bash
rr rollback env:test --dry-run
```

确认后执行：
```bash
rr rollback env:test --yes
```

回滚使用远程 `current` / `previous` release 指针，不在本机解析远程路径。

## 这个设想能否实现
可以实现，但合理边界是：

- Codex 负责理解自然语言、向用户澄清缺失字段、把意图转换成结构化 `rr` 命令。
- remote-runtime 负责配置落盘、策略校验、dry-run、审计、报告、远程命令编排和安全边界。
- 不应该让 Bash CLI 自己解析任意自然语言；那会变成不稳定的字符串规则，无法达到 Codex skill 的体验。

因此最终体验应是：用户用自然语言说目标，Codex 选择 remote-runtime Skill，并在同一个终端内完成计划、确认、执行和验证。

## 安全边界
- 仅允许 SSH alias，不允许裸 IP
- 高风险动作需要确认
- 输出自动脱敏

## 示例
- `examples/springboot-jar/`
- `examples/docker-compose/`
- `examples/multi-env/`
