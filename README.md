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
rr plan deploy env:test
rr status env:all --dry-run
rr run diagnose env:all --dry-run
```

## 安全边界
- 仅允许 SSH alias，不允许裸 IP
- 高风险动作需要确认
- 输出自动脱敏

## 示例
- `examples/springboot-jar/`
- `examples/docker-compose/`
- `examples/multi-env/`
