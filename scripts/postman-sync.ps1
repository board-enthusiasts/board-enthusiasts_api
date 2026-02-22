[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("verify", "login", "push", "all")]
    [string]$Command = "all",

    [ValidateSet("us", "eu")]
    [string]$Region,

    [switch]$SkipLogin,
    [switch]$NoPrepare
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Assert-CommandAvailable {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found on PATH."
    }
}

function Invoke-PostmanLogin {
    param(
        [string]$ApiKey,
        [string]$RegionName
    )

    $args = @("login", "--with-api-key", $ApiKey)

    if (-not [string]::IsNullOrWhiteSpace($RegionName)) {
        $args += @("--region", $RegionName)
    }

    & postman @args
    if ($LASTEXITCODE -ne 0) {
        throw "Postman CLI login failed."
    }
}

function Invoke-WorkspacePush {
    param([bool]$SkipPrepare)

    $args = @("workspace", "push", "--yes")

    if ($SkipPrepare) {
        $args += "--no-prepare"
    }

    & postman @args
    if ($LASTEXITCODE -ne 0) {
        throw "Postman workspace push failed."
    }
}

Assert-CommandAvailable -Name "postman"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Push-Location $repoRoot
try {
    switch ($Command) {
        "verify" {
            Write-Step "Verifying Postman CLI"
            & postman --version
            if ($LASTEXITCODE -ne 0) {
                throw "Postman CLI version check failed."
            }
        }

        "login" {
            if ([string]::IsNullOrWhiteSpace($env:POSTMAN_API_KEY)) {
                throw "POSTMAN_API_KEY is not set. Set it in your shell before running login."
            }

            Write-Step "Logging in to Postman CLI"
            Invoke-PostmanLogin -ApiKey $env:POSTMAN_API_KEY -RegionName $Region
        }

        "push" {
            Write-Step "Pushing local Postman Native Git files to Postman Cloud"
            Invoke-WorkspacePush -SkipPrepare:$NoPrepare
        }

        "all" {
            Write-Step "Verifying Postman CLI"
            & postman --version
            if ($LASTEXITCODE -ne 0) {
                throw "Postman CLI version check failed."
            }

            if (-not $SkipLogin) {
                if ([string]::IsNullOrWhiteSpace($env:POSTMAN_API_KEY)) {
                    throw "POSTMAN_API_KEY is not set. Set it in your shell (or use -SkipLogin if already authenticated)."
                }

                Write-Step "Logging in to Postman CLI"
                Invoke-PostmanLogin -ApiKey $env:POSTMAN_API_KEY -RegionName $Region
            }
            else {
                Write-Host "Skipping Postman CLI login." -ForegroundColor Yellow
            }

            Write-Step "Pushing local Postman Native Git files to Postman Cloud"
            Invoke-WorkspacePush -SkipPrepare:$NoPrepare
        }
    }
}
finally {
    Pop-Location
}
