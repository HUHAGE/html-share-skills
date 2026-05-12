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

Publish HTML or Markdown content to html.huhage.fun via its API and receive a shareable link.

By using this skill, the user agrees to the website terms of use:
https://html.huhage.fun/terms

## API Details

- HTML endpoint: `POST https://html.huhage.fun/api/publish`
- Markdown endpoint: `POST https://html.huhage.fun/api/publish/markdown`
- Content-Type: `application/json; charset=utf-8`
- Auth: `x-api-key` header

## Required Configuration

The API key must be available. Check these locations in order:

1. Environment variable `HTML_SHARE_API_KEY`
2. Environment variable `PUBLISH_API_KEY`
3. macOS Keychain generic password:
   - Service: `html-share`
   - Account: `HTML_SHARE_API_KEY`
4. macOS Keychain generic password:
   - Service: `html-share`
   - Account: `PUBLISH_API_KEY`
5. Skill bundled API key:
   - `huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432`
6. Ask the user for their API key

For stronger local secrecy, prefer storing the API key in macOS Keychain:

```bash
security add-generic-password -a HTML_SHARE_API_KEY -s html-share -w '<api-key>' -U
```

## Publishing Flow

1. Read the source file content (UTF-8)
2. Choose the endpoint:
   - HTML files use `/api/publish` with `content`
   - Markdown files use `/api/publish/markdown` with `markdown`
3. Build JSON body with the content field (required), `title` (optional), `password` (optional 6-digit string), and for Markdown `template` or `templateId` (optional)
4. POST to the API with the `x-api-key` header
5. Parse response to get the share URL

### PowerShell Example

```powershell
$markdownContent = Get-Content -Path "path/to/file.md" -Raw -Encoding UTF8
$bodyJson = @{
  markdown = $markdownContent
  title = "My Report"
  template = "report"
} | ConvertTo-Json -Compress
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)
$response = Invoke-WebRequest -Uri "https://html.huhage.fun/api/publish/markdown" `
  -Method POST `
  -Headers @{ "x-api-key" = $apiKey } `
  -ContentType "application/json; charset=utf-8" `
  -Body $bodyBytes -UseBasicParsing
$response.Content
```

### Bash/curl Example

Use `scripts/publish.sh` for a one-liner:

```bash
scripts/publish.sh <html-or-markdown-file> [title] [password] [template]
scripts/publish.sh README.md "My Report" report
scripts/publish.sh --markdown --template report README.md "My Report"
scripts/publish.sh --markdown --template-id report README.md "My Report"
scripts/publish.sh --html index.html "My Page"
```

The script auto-detects Markdown for `.md`, `.markdown`, `.mdown`, and `.mkd` files. Use `--markdown` or `--html` to override detection.

The script reads `HTML_SHARE_API_KEY` first, then `PUBLISH_API_KEY`. If neither is set, it attempts to read the key from macOS Keychain using service `html-share` and account `HTML_SHARE_API_KEY`, then `PUBLISH_API_KEY`, then falls back to the bundled skill API key.

## Response Format

HTML success (200):
```json
{"success": true, "slug": "aBcDeFgHiJ", "url": "https://html.huhage.fun/share/aBcDeFgHiJ"}
```

Markdown success (200):
```json
{"success": true, "slug": "aBcDeFgHiJ", "url": "https://html.huhage.fun/share/aBcDeFgHiJ", "template": "report"}
```

Errors:
- 401: Invalid API key
- 400: Missing content/markdown or invalid password format (must be 6 digits)
- 500: Server error

## Parameters

| Parameter | Required | Applies to | Description |
|-----------|----------|------------|-------------|
| `content` | Yes | HTML | HTML content string |
| `markdown` | Yes | Markdown | Markdown content string |
| `title` | No | HTML, Markdown | Page title (auto-generated if omitted) |
| `password` | No | HTML, Markdown | 6-digit numeric password for access protection |
| `template` / `templateId` | No | Markdown | One of `journal`, `report`, `poster`, `dark`, `grid` |

## Notes

- Using this skill means the user agrees to the website terms of use: https://html.huhage.fun/terms
- JSON escaping is critical: backslashes, quotes, and newlines must be properly escaped
- Use UTF-8 encoding for the request body to support Chinese and other non-ASCII characters
- Markdown templates are only supported by `/api/publish/markdown`
- The returned URL is immediately accessible and shareable
