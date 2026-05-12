# publish.ps1 - Publish an HTML or Markdown file to html.huhage.fun
# Usage:
#   .\publish.ps1 -File <path> [-Title <title>] [-Password <6-digit>] [-Template <template>|-TemplateId <template>] [-Markdown|-Html]
#   .\publish.ps1 -HtmlFile <path> [-Title <title>] [-Password <6-digit>]
#   .\publish.ps1 -MarkdownFile <path> [-Title <title>] [-Password <6-digit>] [-Template <template>|-TemplateId <template>]
# Uses -ApiKey, HTML_SHARE_API_KEY/PUBLISH_API_KEY, then the bundled skill key.

param(
    [string]$File = "",
    [string]$HtmlFile = "",
    [string]$MarkdownFile = "",
    [string]$Title = "",
    [string]$Password = "",
    [ValidateSet("journal", "report", "poster", "dark", "grid")]
    [string]$Template = "",
    [ValidateSet("journal", "report", "poster", "dark", "grid")]
    [string]$TemplateId = "",
    [switch]$Html,
    [switch]$Markdown,
    [string]$ApiKey = ""
)

if (-not $ApiKey) { $ApiKey = $env:HTML_SHARE_API_KEY }
if (-not $ApiKey) { $ApiKey = $env:PUBLISH_API_KEY }
if (-not $ApiKey) { $ApiKey = "huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432" }
if (-not $ApiKey) { Write-Error "API key required. Set HTML_SHARE_API_KEY/PUBLISH_API_KEY or use -ApiKey"; exit 1 }

if ($HtmlFile) {
    $File = $HtmlFile
    $Html = $true
}
if ($MarkdownFile) {
    $File = $MarkdownFile
    $Markdown = $true
}

if (-not $File) { Write-Error "File required. Use -File, -HtmlFile, or -MarkdownFile"; exit 1 }
if (-not (Test-Path $File)) { Write-Error "File not found: $File"; exit 1 }
if ($Html -and $Markdown) { Write-Error "Choose only one of -Html or -Markdown"; exit 1 }
if ($Template -and $TemplateId) { Write-Error "Choose only one of -Template or -TemplateId"; exit 1 }
if ($Password -and ($Password -notmatch '^\d{6}$')) { Write-Error "Password must be a 6-digit numeric string"; exit 1 }

$isMarkdown = $false
if ($Markdown) {
    $isMarkdown = $true
} elseif ($Html) {
    $isMarkdown = $false
} elseif ($File -match '\.(md|markdown|mdown|mkd)$') {
    $isMarkdown = $true
}

$content = Get-Content -Path $File -Raw -Encoding UTF8

if ($isMarkdown) {
    $body = @{ markdown = $content }
    if ($Template) { $body.template = $Template }
    if ($TemplateId) { $body.templateId = $TemplateId }
    $endpoint = "https://html.huhage.fun/api/publish/markdown"
} else {
    $body = @{ content = $content }
    $endpoint = "https://html.huhage.fun/api/publish"
}

if ($Title) { $body.title = $Title }
if ($Password) { $body.password = $Password }

$bodyJson = $body | ConvertTo-Json -Compress

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

try {
    $response = Invoke-WebRequest -Uri $endpoint `
        -Method POST `
        -Headers @{ "x-api-key" = $ApiKey } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    if ($result.success) {
        Write-Host "Published: $($result.url)"
    }
    $response.Content
} catch {
    Write-Error $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Error $reader.ReadToEnd()
    }
}
