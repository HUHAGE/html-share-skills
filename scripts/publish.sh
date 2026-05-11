#!/usr/bin/env bash
# publish.sh - Publish an HTML file to html.huhage.fun
# Usage: publish.sh <html-file> [title] [password]
# Uses HTML_SHARE_API_KEY, macOS Keychain, then the bundled skill key.

set -euo pipefail

HTML_FILE="${1:?Usage: publish.sh <html-file> [title] [password]}"
TITLE="${2:-}"
PASSWORD="${3:-}"

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  if command -v security >/dev/null 2>&1; then
    HTML_SHARE_API_KEY="$(security find-generic-password -a HTML_SHARE_API_KEY -s html-share -w 2>/dev/null || true)"
  fi
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  HTML_SHARE_API_KEY="huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432"
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  echo "Error: HTML_SHARE_API_KEY is not set, no Keychain item was found, and no bundled key is available" >&2
  exit 1
fi

if [ ! -f "$HTML_FILE" ]; then
  echo "Error: File not found: $HTML_FILE" >&2
  exit 1
fi

# Read and escape HTML content for JSON
CONTENT=$(cat "$HTML_FILE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

# Build JSON body
if [ -n "$PASSWORD" ]; then
  BODY="{\"content\":${CONTENT},\"title\":\"${TITLE}\",\"password\":\"${PASSWORD}\"}"
elif [ -n "$TITLE" ]; then
  BODY="{\"content\":${CONTENT},\"title\":\"${TITLE}\"}"
else
  BODY="{\"content\":${CONTENT}}"
fi

# Publish
RESPONSE=$(curl -s -X POST "https://html.huhage.fun/api/publish" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "x-api-key: ${HTML_SHARE_API_KEY}" \
  -d "$BODY")

echo "$RESPONSE"

# Extract URL if successful
URL=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('url',''))" 2>/dev/null || true)
if [ -n "$URL" ]; then
  echo ""
  echo "Published: $URL"
fi
