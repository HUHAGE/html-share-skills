#!/usr/bin/env bash
# publish.sh - Publish an HTML or Markdown file to html.huhage.fun
# Usage:
#   publish.sh [--html|--markdown] [--template <template>] <file> [title] [password] [template]
#   publish.sh <html-file> [title] [password]
#   publish.sh <markdown-file> [title] [password] [template]
# Uses HTML_SHARE_API_KEY/PUBLISH_API_KEY, macOS Keychain, then the bundled skill key.

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  publish.sh [--html|--markdown] [--template <template>] <file> [title] [password] [template]
  publish.sh <html-file> [title] [password]
  publish.sh <markdown-file> [title] [password] [template]

Markdown templates: journal, report, poster, dark, grid
EOF
}

MODE=""
TEMPLATE=""
TEMPLATE_FIELD="template"
POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --html)
      MODE="html"
      ;;
    --markdown|--md)
      MODE="markdown"
      ;;
    --template)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Error: --template requires a value" >&2
        usage
        exit 1
      fi
      TEMPLATE="$1"
      TEMPLATE_FIELD="template"
      ;;
    --template-id)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Error: --template-id requires a value" >&2
        usage
        exit 1
      fi
      TEMPLATE="$1"
      TEMPLATE_FIELD="templateId"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        POSITIONAL+=("$1")
        shift
      done
      break
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      ;;
  esac
  shift
done

if [ "${#POSITIONAL[@]}" -lt 1 ]; then
  usage
  exit 1
fi

INPUT_FILE="${POSITIONAL[0]}"
TITLE="${POSITIONAL[1]:-}"
PASSWORD="${POSITIONAL[2]:-}"
if [ -z "$TEMPLATE" ]; then
  TEMPLATE="${POSITIONAL[3]:-}"
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  HTML_SHARE_API_KEY="${PUBLISH_API_KEY:-}"
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  if command -v security >/dev/null 2>&1; then
    HTML_SHARE_API_KEY="$(security find-generic-password -a HTML_SHARE_API_KEY -s html-share -w 2>/dev/null || true)"
  fi
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  if command -v security >/dev/null 2>&1; then
    HTML_SHARE_API_KEY="$(security find-generic-password -a PUBLISH_API_KEY -s html-share -w 2>/dev/null || true)"
  fi
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  HTML_SHARE_API_KEY="huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432"
fi

if [ -z "${HTML_SHARE_API_KEY:-}" ]; then
  echo "Error: HTML_SHARE_API_KEY/PUBLISH_API_KEY is not set, no Keychain item was found, and no bundled key is available" >&2
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: File not found: $INPUT_FILE" >&2
  exit 1
fi

if [ -z "$MODE" ]; then
  case "$INPUT_FILE" in
    *.[mM][dD]|*.[mM][aA][rR][kK][dD][oO][wW][nN]|*.[mM][dD][oO][wW][nN]|*.[mM][kK][dD])
      MODE="markdown"
      ;;
    *)
      MODE="html"
      ;;
  esac
fi

if [ "$MODE" = "markdown" ] && [ -z "$TEMPLATE" ]; then
  case "$PASSWORD" in
    journal|report|poster|dark|grid)
      TEMPLATE="$PASSWORD"
      PASSWORD=""
      ;;
  esac
fi

if [ -n "$PASSWORD" ] && ! [[ "$PASSWORD" =~ ^[0-9]{6}$ ]]; then
  echo "Error: Password must be a 6-digit numeric string" >&2
  exit 1
fi

if [ "$MODE" = "markdown" ] && [ -n "$TEMPLATE" ]; then
  case "$TEMPLATE" in
    journal|report|poster|dark|grid) ;;
    *)
      echo "Error: Invalid Markdown template: $TEMPLATE" >&2
      echo "Allowed templates: journal, report, poster, dark, grid" >&2
      exit 1
      ;;
  esac
fi

if [ "$MODE" = "markdown" ]; then
  ENDPOINT="https://html.huhage.fun/api/publish/markdown"
elif [ "$MODE" = "html" ]; then
  ENDPOINT="https://html.huhage.fun/api/publish"
else
  echo "Error: Invalid mode: $MODE" >&2
  exit 1
fi

BODY=$(python3 - "$MODE" "$INPUT_FILE" "$TITLE" "$PASSWORD" "$TEMPLATE" "$TEMPLATE_FIELD" <<'PY'
import json
import sys
from pathlib import Path

mode, input_file, title, password, template, template_field = sys.argv[1:7]
text = Path(input_file).read_text(encoding="utf-8")

if mode == "markdown":
    body = {"markdown": text}
    if template:
        body[template_field] = template
else:
    body = {"content": text}

if title:
    body["title"] = title
if password:
    body["password"] = password

print(json.dumps(body, ensure_ascii=False))
PY
)

# Publish
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
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
