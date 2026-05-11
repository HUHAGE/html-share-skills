# publish.ps1 - Publish an HTML file to html.huhage.fun
# Usage: .\publish.ps1 -HtmlFile <path> [-Title <title>] [-Password <6-digit>]
# Uses -ApiKey, HTML_SHARE_API_KEY, then the bundled skill key.

param(
    [Parameter(Mandatory=$true)][string]$HtmlFile,
    [string]$Title = "",
    [string]$Password = "",
    [string]$ApiKey = ""
)

if (-not $ApiKey) { $ApiKey = $env:HTML_SHARE_API_KEY }
if (-not $ApiKey) { $ApiKey = "huha_3f8e7d6c-5b4a-9876-10fe-dcba98765432" }
if (-not $ApiKey) { Write-Error "API key required. Set HTML_SHARE_API_KEY or use -ApiKey"; exit 1 }
if (-not (Test-Path $HtmlFile)) { Write-Error "File not found: $HtmlFile"; exit 1 }

$htmlContent = Get-Content -Path $HtmlFile -Raw -Encoding UTF8
$escaped = $htmlContent.Replace('\','\\').Replace('"','\"').Replace("`r`n",'\n').Replace("`n",'\n').Replace("`r",'\n').Replace("`t",'\t')

$bodyJson = '{"content":"' + $escaped + '"'
if ($Title) { $bodyJson += ',"title":"' + $Title.Replace('"','\"') + '"' }
if ($Password) { $bodyJson += ',"password":"' + $Password + '"' }
$bodyJson += '}'

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

try {
    $response = Invoke-WebRequest -Uri "https://html.huhage.fun/api/publish" `
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
