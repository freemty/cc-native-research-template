---
name: init-project
description: "Use when setting up a new research project — initializes directory skeleton, CLAUDE.md, .gitignore, pipeline state, and reference scripts in the user's existing project."
tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# Init Project

在用户的现有项目中初始化研究项目骨架。**幂等**：可安全重复运行，已存在的文件/目录一律跳过，不会覆盖或删除。

所有输出和提示均使用**中文**。

---

## 执行流程

### Step 1: 检测现有结构

1. 使用 Bash 运行 `git status --porcelain` 检查 git 仓库状态：
   - 若输出非空（有未提交更改），**警告用户**并询问是否继续：
     > "检测到 git 工作区有未提交更改。继续将在此基础上写入文件。确认继续？(Y/n)"
   - 若用户回答 n，立即停止。

2. 检查以下路径是否存在，记录结果（用于后续 skip 判断）：
   - `CLAUDE.md`
   - `exp/`
   - `docs/`
   - `.pipeline-state.json`
   - `.gitignore`

3. 输出检测摘要（中文），例如：
   > 检测结果：CLAUDE.md 不存在 | exp/ 已存在 | docs/ 不存在 | .pipeline-state.json 不存在 | .gitignore 已存在

---

### Step 2: 收集项目信息

**逐一提问**，每问完一个等待用户回答后再问下一个：

1. **项目名称**（Project name）
   > "请输入项目名称（例如：my-nlp-research）："

2. **一句话描述**（One-line description）
   > "请输入项目一句话描述（例如：研究大语言模型在低资源场景下的推理能力）："

3. **研究领域**（Research domain）
   > "请输入研究领域（例如：NLP / computer vision / reinforcement learning）："

4. **计算环境**（Compute environment）
   > "请选择计算环境：local / remote-gpu / cloud（默认 local）："
   - 若用户直接回车，默认 `local`

将以上四个值保存为变量：`{project-name}`、`{description}`、`{domain}`、`{compute_env}`。

---

### Step 3: 创建目录结构

**原则：只创建不存在的文件/目录。已存在则跳过并记录。**

按下列清单逐项处理：

#### 3.1 实验目录

- `exp/.gitkeep` — 若 `exp/` 不存在则创建目录并写入空文件
- `exp/summary.md` — 若不存在则写入以下内容：

```markdown
# Experiment Summary

Cross-experiment flight recorder. One row per experiment.

| Exp ID | Motivation | Status | Key Finding |
|--------|-----------|--------|-------------|
```

#### 3.2 文档目录

以下目录若不存在则创建并写入 `.gitkeep`：
- `docs/papers/`
- `docs/specs/`
- `docs/weekly/`
- `docs/archive/`

- `docs/papers/landscape.md` — 若不存在则写入以下占位内容：

```markdown
# Domain Literature Landscape

> Research domain: {domain}

## Key Papers

(待填写 — 使用 @domain-expert 协助整理文献)

## Research Gaps

(待填写)
```

将 `{domain}` 替换为 Step 2 收集的研究领域。

#### 3.3 其他目录

- `slides/.gitkeep` — 若 `slides/` 不存在则创建

#### 3.4 脚本文件

**插件路径**：通过 `SKILL.md` 所在目录推导插件根目录。
- 此 SKILL.md 位于 `<plugin_root>/skills/init-project/SKILL.md`
- 因此 `<plugin_root>` = SKILL.md 向上两级目录
- 所有 references 文件读取自 `<plugin_root>/references/`

逐一处理（若目标文件已存在则跳过）：

| 目标路径 | 来源（相对插件根） |
|---------|----------------|
| `scripts/launch_exp.py` | `references/launch_exp.py` |
| `scripts/monitor_exp.sh` | `references/monitor_exp.sh` |
| `scripts/download_results.sh` | `references/download_results.sh` |
| `viewer/app.py` | `references/viewer-app.py` |
| `viewer/static/index.html` | `references/viewer-static/index.html` |

操作步骤：
1. 用 Read 读取插件 references 中的源文件内容
2. 若目标文件不存在，用 Write 写入
3. 确保父目录存在（必要时用 Bash `mkdir -p` 创建）

#### 3.5 pipeline 状态文件

若 `.pipeline-state.json` 不存在，写入：

```json
{
  "project_name": "{project-name}",
  "description": "{description}",
  "domain": "{domain}",
  "compute_env": "{compute_env}",
  "current_exp": null,
  "stage": "dev",
  "skill_updated_at": null
}
```

将四个占位符替换为 Step 2 收集的值。

---

### Step 4: 生成 CLAUDE.md

**从插件读取模板：**

1. 用 Read 读取 `<plugin_root>/references/claude-md-template.md`
2. 替换以下占位符：
   - `{project-name}` → Step 2 的项目名称
   - `{description}` → Step 2 的一句话描述
   - `{date}` → 今天日期，格式 `YYYY-MM-DD`

**写入规则：**

- **若 `CLAUDE.md` 不存在**：直接写入替换后的完整模板。

- **若 `CLAUDE.md` 已存在**：
  1. 用 Read 读取现有 CLAUDE.md 内容
  2. 解析现有的 `## ` 二级标题列表（h2 sections）
  3. 解析模板的 `## ` 二级标题列表
  4. 找出模板中**存在但现有文件中缺失**的 section
  5. 仅将缺失的 section（含其内容，直到下一个 `## ` 或文件末尾）**追加**到现有 CLAUDE.md 末尾
  6. **绝对不删除、不修改**现有 section
  7. 若所有 section 均已存在，输出"CLAUDE.md 已包含所有模板 section，跳过"

---

### Step 5: 追加 .gitignore 规则

1. 用 Read 读取 `<plugin_root>/references/gitignore-rules.md`

2. 若 `.gitignore` 不存在，先用 Write 创建空文件（内容为空字符串）

3. 用 Read 读取现有 `.gitignore` 内容，将所有行存入集合 `existing_lines`

4. 逐行处理 `gitignore-rules.md` 的每一行：
   - **空行**：追加空行（用于格式间隔）
   - **注释行**（以 `#` 开头）：**始终追加**（作为 section 标记）
   - **规则行**（其他）：
     - strip 首尾空白
     - 若该行**不在** `existing_lines` 中，则追加
     - 若已存在，跳过

5. 将所有待追加内容一次性用 Edit 写入 `.gitignore` 末尾

---

### Step 6: 输出摘要

以中文输出结构化摘要，格式如下：

```
=== /init-project 完成 ===

已创建：
  + exp/summary.md
  + docs/papers/landscape.md
  + docs/specs/.gitkeep
  + docs/weekly/.gitkeep
  + docs/archive/.gitkeep
  + slides/.gitkeep
  + scripts/launch_exp.py
  + scripts/monitor_exp.sh
  + scripts/download_results.sh
  + viewer/app.py
  + viewer/static/index.html
  + .pipeline-state.json
  + CLAUDE.md（新建）

已跳过（已存在）：
  ~ exp/（目录已存在）
  ~ docs/papers/landscape.md（文件已存在）

已更新：
  ~ CLAUDE.md（追加 2 个缺失 section）
  ~ .gitignore（追加 8 条规则）

=== 建议后续步骤 ===

1. 检查变更：
   git diff

2. 确认无误后提交：
   git add -A && git commit -m "chore: init research project skeleton"

3. 开始第一个实验：
   /new-experiment
```

根据实际操作结果填写"已创建"、"已跳过"、"已更新"列表。

---

## 错误处理

- 读取插件 references 文件失败：输出错误信息，说明 `<plugin_root>/references/` 中缺少对应文件，跳过该文件继续执行其余步骤
- 写入文件失败（权限等）：输出错误，跳过该文件，最终摘要中标记为 `! 写入失败`
- 任何步骤失败不中断整体流程，继续执行后续步骤，最终汇总所有错误

---

## 幂等性保证

- 已存在的文件：**只读，不覆盖**
- `.gitignore` 规则：**逐行去重，不重复追加**
- `CLAUDE.md` section：**仅追加缺失 section**
- 目录：已存在则跳过 `mkdir`
- `.pipeline-state.json`：已存在则完整跳过（不更新字段）
