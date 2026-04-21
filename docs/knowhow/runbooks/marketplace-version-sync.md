# Marketplace 版本同步

> 发布新版本后，必须同步更新 labmate-marketplace 仓库

## 开发端：发布新版本

```bash
# 在 labmate 源码仓库的 dev 分支上，确保所有改动已 commit
./scripts/release.sh
```

release.sh 自动完成：
1. 检查 dev 分支 + 无未提交改动
2. merge dev → main，push 两个分支
3. 同步 marketplace.json 版本号，commit + push marketplace 仓库
4. 修复 installed_plugins.json 中所有 scope 的版本和 cache 路径

完成后在 **新会话** 中执行 `/reload-plugins` 验证。

### 手动发版（release.sh 不可用时）

```bash
MARKETPLACE=~/.claude/plugins/marketplaces/labmate-marketplace

# 1. merge dev → main + push
git checkout main && git merge dev --no-ff && git push origin main
git checkout dev && git push origin dev

# 2. 同步 marketplace.json 版本号
# 编辑 $MARKETPLACE/.claude-plugin/marketplace.json → plugins[0].version

# 3. commit + push marketplace
cd $MARKETPLACE
git add .claude-plugin/marketplace.json
git commit -m "chore: bump labmate version to vX.Y.Z"
git push

# 4. 手动修复 installed_plugins.json（见 Gotcha 章节）
```

## 用户端：安装 / 更新

### 首次安装

```bash
/plugin marketplace add freemty/labmate-marketplace
/plugin install labmate@labmate-marketplace
```

### 更新到最新版

```bash
/plugin update
```

然后在 **新会话** 中执行 `/reload-plugins`（当前会话缓存了旧的 base directory，reload 不够）。

### 验证

```bash
/plugin                  # 确认版本号
/reload-plugins          # 在新会话中加载新 skill
```

## Gotcha: 当前会话 cache 路径锁定

Plugin loader 在会话启动时锁定 installPath。之后 `/reload-plugins` 只刷新 skill 列表，不重新解析 installPath。这意味着：
- 在当前会话中 `/reload-plugins` → 内容会从旧 installPath 重新 clone（目录名错、路径错，但内容可能是新的）
- **必须在新会话中验证**

发版后的正确验证方式：退出当前会话 → 开新会话 → `/reload-plugins` → 检查 base directory 路径。

## Gotcha: installed_plugins.json

`/plugin update` 只更新 user-scope 记录，不碰 project-scope 的。如果某个项目曾以 project-scope 安装过 labmate，`installed_plugins.json` 里会残留旧版 installPath，plugin loader 优先用 project-scope → 加载旧 cache。

`scripts/release.sh` 已包含自动修正步骤。如果手动发版，检查：
```bash
grep -A5 "labmate@labmate-marketplace" ~/.claude/plugins/installed_plugins.json
```

## Gotcha: gitCommitSha 必须指向 marketplace repo

`installed_plugins.json` 的 `gitCommitSha` 字段决定 plugin loader checkout 哪个 commit。这个 sha 必须是 **marketplace repo** (`freemty/labmate-marketplace`) 的 commit，不是源码 repo (`freemty/labmate`) 的。

如果 sha 指向源码 repo（在 marketplace repo 里找不到），loader 会 fallback 到旧版本。

`scripts/release.sh` 已修复此问题（从 marketplace repo 取 sha）。手动验证：
```bash
# 查看 installed_plugins.json 中的 sha
grep -A2 "gitCommitSha" ~/.claude/plugins/installed_plugins.json | grep -A1 labmate

# 确认 sha 存在于 marketplace repo
cd ~/.claude/plugins/marketplaces/labmate-marketplace
git cat-file -t <sha>  # 应输出 "commit"
```

## Gotcha: 旧 cache 目录残留

发布后旧版本 cache 不会自动删除（`release.sh` 已包含自动清理步骤）。手动检查：
```bash
ls ~/.claude/plugins/cache/labmate-marketplace/labmate/
# 应该只有当前版本
```

## Notes
- Date: 2026-04-08, updated 2026-04-21
- Marketplace repo: `freemty/labmate-marketplace`
- 本地路径: `~/.claude/plugins/marketplaces/labmate-marketplace/`
