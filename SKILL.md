---
name: html-share
description: >
  Publish HTML or Markdown content to html.huhage.fun and get a shareable link.
  Use when: (1) deploying single-page HTML apps/games/demos to a public URL,
  (2) sharing HTML snippets, Markdown documents, reports, or previews with others,
  (3) user asks to publish/deploy/share HTML or Markdown content online.
  Supports optional title, template, and password protection.
---

# HTML Share

Publish HTML or Markdown content to html.huhage.fun and receive a shareable link.

By using this skill, the user agrees to the website terms of use:
https://html.huhage.fun/terms

## Configuration

No user configuration is required. Do not ask the user to provide credentials before publishing.

## Usage

Use this skill when the user asks an AI agent to publish or share HTML or Markdown content online.

Do not use a browser or the website UI to publish content. This skill ships with publishing scripts; agents must call the script/API directly.

The agent should:

- Read the HTML or Markdown content from the user-provided file or message
- If the content is only provided inline, save it to a temporary `.html` or `.md` file first
- Publish it by running the bundled script:
  - macOS/Linux: `scripts/publish.sh [--html|--markdown] <file> [title] [password] [template]`
  - Windows PowerShell: `scripts/publish.ps1 -File <path> [-Html|-Markdown] [-Title <title>] [-Password <6-digit>] [-Template <template>]`
- Return the generated share link to the user

The script automatically uses `HTML_SHARE_API_KEY`, `PUBLISH_API_KEY`, macOS Keychain, or the bundled skill key. Do not ask the user for credentials before publishing.

Examples:

```bash
scripts/publish.sh --html ./page.html "My Page"
scripts/publish.sh --markdown ./report.md "Weekly Report" "" report
```

```powershell
.\scripts\publish.ps1 -HtmlFile .\page.html -Title "My Page"
.\scripts\publish.ps1 -MarkdownFile .\report.md -Title "Weekly Report" -Template report
```

If publishing fails, report the script error and retry only after fixing the file, arguments, or network/API issue. Do not fall back to browser-based publishing unless the user explicitly asks for manual browser operation.

Example user requests:

- "Use html-share to publish this HTML file."
- "Use html-share to publish this Markdown content."
- "Share this report online with html-share."
