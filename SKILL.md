---
name: html-share
description: >
  Publish HTML content to html.huhage.fun and get a shareable link.
  Use when: (1) deploying single-page HTML apps/games/demos to a public URL,
  (2) sharing HTML snippets or previews with others,
  (3) user asks to publish/deploy/share HTML content online.
  Supports optional title and password protection.
---

# HTML Share

Publish HTML content to html.huhage.fun via its API and receive a shareable link.

By using this skill, the user agrees to the website terms of use:
https://html.huhage.fun/terms

## API Details

- Endpoint: `POST https://html.huhage.fun/api/publish`
- Content-Type: `application/json; charset=utf-8`
- Auth: `x-api-key` header

## Required Configuration

The API key must be available. Check these locations in order:

1. Environment variable `HTML_SHARE_API_KEY`
2. macOS Keychain generic password:
   - Service: `html-share`
   - Account: `HTML_SHARE_API_KEY`
3. Skill bundled API key:
   - `huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432`
4. Ask the user for their API key

For stronger local secrecy, prefer storing the API key in macOS Keychain:

```bash
security add-generic-password -a HTML_SHARE_API_KEY -s html-share -w '<api-key>' -U
```

## Publishing Flow

1. Read the HTML file content (UTF-8)
2. Build JSON body with `content` (required), `title` (optional), `password` (optional 6-digit string)
3. POST to the API with the `x-api-key` header
4. Parse response to get the share URL

### PowerShell Example

```powershell
$htmlContent = Get-Content -Path "path/to/file.html" -Raw -Encoding UTF8
$escaped = $htmlContent.Replace('\','\\').Replace('"','\"').Replace("`r`n",'\n').Replace("`n",'\n').Replace("`r",'\n').Replace("`t",'\t')
$bodyJson = '{"content":"' + $escaped + '","title":"My Page"}'
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)
$response = Invoke-WebRequest -Uri "https://html.huhage.fun/api/publish" `
  -Method POST `
  -Headers @{ "x-api-key" = $apiKey } `
  -ContentType "application/json; charset=utf-8" `
  -Body $bodyBytes -UseBasicParsing
$response.Content
```

### Bash/curl Example

Use `scripts/publish.sh` for a one-liner:

```bash
scripts/publish.sh <html-file> [title] [password]
```

The script reads `HTML_SHARE_API_KEY` first. If it is not set, it attempts to read the key from macOS Keychain using service `html-share` and account `HTML_SHARE_API_KEY`, then falls back to the bundled skill API key.

## Response Format

Success (200):
```json
{"success": true, "slug": "aBcDeFgHiJ", "url": "https://html.huhage.fun/share/aBcDeFgHiJ"}
```

Errors:
- 401: Invalid API key
- 400: Missing content or invalid password format (must be 6 digits)
- 500: Server error

## Parameters

| Parameter  | Required | Description |
|-----------|----------|-------------|
| `content` | Yes      | HTML content string |
| `title`   | No       | Page title (auto-generated if omitted) |
| `password` | No      | 6-digit numeric password for access protection |

## Notes

- Using this skill means the user agrees to the website terms of use: https://html.huhage.fun/terms
- JSON escaping is critical: backslashes, quotes, and newlines must be properly escaped
- Use UTF-8 encoding for the request body to support Chinese and other non-ASCII characters
- The returned URL is immediately accessible and shareable
