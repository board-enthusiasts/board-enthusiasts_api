param(
    [string]$CollectionPath = "postman/collections/board-enthusiasts-api.contract-tests.postman_collection.json",
    [string]$EnvironmentPath = "postman/environments/board-enthusiasts_local.postman_environment.json",
    [string]$BaseUrl = "http://127.0.0.1:8787",
    [ValidateSet("live", "mock")]
    [string]$ContractExecutionMode = "live",
    [string]$DeveloperAccessToken = "",
    [string]$ModeratorAccessToken = "",
    [string]$ReportPath = "postman-cli-reports/local-contract-tests.xml"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$apiRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path

if (-not (Get-Command postman -ErrorAction SilentlyContinue)) {
    throw "Postman CLI is not installed or not on PATH. Install it, then rerun this script."
}

Push-Location $apiRoot
try {
    $reportDirectory = Split-Path -Parent $ReportPath
    if ($reportDirectory) {
        New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null
    }

    $postmanArgs = @(
        "collection", "run", $CollectionPath,
        "--environment", $EnvironmentPath,
        "--env-var", "baseUrl=$BaseUrl",
        "--env-var", "contractExecutionMode=$ContractExecutionMode",
        "--bail", "failure",
        "--reporters", "cli,junit",
        "--reporter-junit-export", $ReportPath,
        "--working-dir", $apiRoot
    )

    if ($DeveloperAccessToken) {
        $postmanArgs += @("--env-var", "developerAccessToken=$DeveloperAccessToken")
    }

    if ($ModeratorAccessToken) {
        $postmanArgs += @("--env-var", "moderatorAccessToken=$ModeratorAccessToken")
    }

    if ($BaseUrl.StartsWith("https://localhost") -or $BaseUrl.StartsWith("https://127.0.0.1")) {
        $postmanArgs += "--insecure"
    }

    & postman @postmanArgs

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
