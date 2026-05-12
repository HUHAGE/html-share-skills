# HTML Share Skill

[中文](#中文) | [English](#english)

---

## 中文

`html-share` 是一个面向 Agent 的通用 Skill，用于把 HTML 或 Markdown 发布到 `https://html.huhage.fun`，并返回一个可以分享的网页链接。

它适用于 Codex 以及其他支持 Skill、脚本或工具调用的 Agent。用户不需要关心任何技术细节，只需要告诉 AI 调用这个 Skill 来发布内容。

使用本 Skill 即表示用户同意网站服务条款：
https://html.huhage.fun/terms

### 安装

告诉 AI 或 Agent：

```text
请帮我从 GitHub 安装 html-share skill：https://github.com/HUHAGE/html-share-skills.git
```

### 能做什么

- 发布 HTML 页面、单页应用、小游戏、交互式 Demo 或网页原型
- 发布 Markdown 文档、报告、笔记、预览内容或说明文档
- 返回一个可直接访问和分享的链接
- 支持中文和其他 UTF-8 内容

### 最简单的用法

直接告诉 AI 或 Agent：

```text
请使用 html-share skill 发布这个 HTML 文件。
```

或者：

```text
请使用 html-share skill 发布这段 Markdown 内容。
```

AI/Agent 会读取 HTML 或 Markdown 内容，调用 `html-share` Skill 完成发布，并把分享链接返回给你。

---

## English

`html-share` is a general-purpose Skill for agents. It publishes HTML or Markdown content to `https://html.huhage.fun` and returns a shareable web link.

It works with Codex and other agents that can use Skills, scripts, or tool calls. Users do not need to handle any technical details. Just ask the AI to use this Skill to publish the content.

By using this Skill, the user agrees to the website terms of use:
https://html.huhage.fun/terms

### Installation

Tell the AI or agent:

```text
Please install the html-share skill from GitHub: https://github.com/HUHAGE/html-share-skills.git
```

### What It Does

- Publishes HTML pages, single-page apps, games, interactive demos, or web prototypes
- Publishes Markdown documents, reports, notes, previews, or documentation
- Returns a directly accessible share link
- Supports Chinese and other UTF-8 content

### Only Usage

Tell the AI or agent:

```text
Please use the html-share skill to publish this HTML file.
```

Or:

```text
Please use the html-share skill to publish this Markdown content.
```

The AI/agent will read the HTML or Markdown content, call the `html-share` Skill, publish it, and return the share link.
