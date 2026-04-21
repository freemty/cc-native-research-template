# Marketplace 版本同步

> 发布新版本后，必须同步更新 labmate-marketplace 仓库

## Problem
`/plugin` 读取 marketplace repo 而非源码仓库的版本号。两者需手动保持同步。

## Cause
Claude Code plugin 系统从 `freemty/labmate-marketplace` 获取版本信息（README.md 中的 skill/agent 数量等）。源码 push 到 main 不会自动更新 marketplace。

## Solution

发布 checklist（每次 version bump 后执行）：

1. **源码仓库** — bump version + merge dev → main + push both
2. **Marketplace** — 更新 README.md（agent/skill 数量等描述）+ commit + push
3. **验证** — `/plugin` 确认版本号，`/reload-plugins` 加载新 skill

## Commands
```bash
MARKETPLACE=~/.claude/plugins/marketplaces/labmate-marketplace

# 1. 更新 marketplace.json 版本号（关键！loader 依赖此字段）
# 编辑 $MARKETPLACE/.claude-plugin/marketplace.json → plugins[0].version

# 2. 更新 README.md（agent/skill 数量等描述）

# 3. commit & push
cd $MARKETPLACE
git add .claude-plugin/marketplace.json README.md
git commit -m "chore: bump labmate version to vX.Y.Z"
git push

# 4. 验证: /plugin update → /reload-plugins → 确认 skill 数量
```

## Notes
- Date: 2026-04-08, updated 2026-04-21
- Marketplace repo: `freemty/labmate-marketplace`
- 本地路径: `~/.claude/plugins/marketplaces/labmate-marketplace/`
