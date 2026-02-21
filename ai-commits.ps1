git add -N .

$status = git status --porcelain

if (-not $status) {
    Write-Host "No changes to commit"
    exit
}

$diff = git diff HEAD

$body = @{
    diff = $diff
    status = $status
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod `
    -Uri "http://localhost:5678/webhook-test/4d35f21c-3284-4bd1-93d1-46142fd44010" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

$msg = $response.text

if (-not $msg) {
    Write-Host "AI did not return a commit message"
    exit
}

$msg = $msg.Trim()

Write-Host "AI commit message: $msg"

git add .
git commit -m "$msg"
git push