
param(
    [string] $Configuration = "Debug",
    [string] $Architecture = "x64",
    [string[]] $Targets = @("Build", "Tests"),
    [switch] $Help,
    [Parameter(Position=0, ValueFromRemainingArguments=$true)] $ExtraParameters )

if($Help)
{
    Write-Host "Usage: build [[-Help] [-Targets <TARGETS...>] "
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Targets <TARGETS...>              Comma separated build targets to run (Build, Tests; Default is a full build and tests)"
    Write-Host "  -Help                              Display this help message"
    exit 0
}

#make path absolute
$RepoRoot = "$PSScriptRoot"

function Install-DotnetSdk([string] $sdkVersion, [string] $sdkBranch)
{
    Write-Host "# Install .NET Core Sdk versione '$sdkVersion'" -foregroundcolor "magenta"
    $sdkInstallScriptUrl = "https://raw.githubusercontent.com/dotnet/cli/$sdkBranch/scripts/obtain/dotnet-install.ps1"
    $sdkInstallScriptPath = ".dotnetsdk\dotnet_cli_install.ps1"
    Write-Host "Downloading sdk install script '$sdkInstallScriptUrl' to '$sdkInstallScriptPath'"
    mkdir "$RepoRoot\.dotnetsdk" -Force | Out-Null
    try {
      Invoke-WebRequest $sdkInstallScriptUrl -OutFile "$RepoRoot\$sdkInstallScriptPath"
    } catch {
      Write-Host "failed $_.Exception"
      exit 1
    }

    Write-Host "Running sdk install script..."
    ./.dotnetsdk/dotnet_cli_install.ps1 -InstallDir ".dotnetsdk\sdk-$sdkVersion" -Version $sdkVersion
}

function Run-Cmd
{
  param( [string]$exe, [string]$arguments )
  Write-Host "$exe $arguments" -ForegroundColor "Blue"
  iex "$exe $arguments 2>&1" | Out-Host
  if ($LastExitCode -ne 0) {
    throw "Command failed with exit code $LastExitCode."
  }
  Write-Host ""
}

function Using-Sdk ([string] $sdkVersion)
{
  $sdkPath = "$RepoRoot\.dotnetsdk\sdk-$sdkVersion"
  Write-Host "# Using sdk '$sdkVersion'" -foregroundcolor "magenta"
  $env:Path = "$sdkPath;$env:Path"
  Run-Cmd "dotnet" "--version"
}

# main

$sdkStable = '1.0.1'

Install-DotnetSdk $sdkStable 'rel/1.0.0'
Install-DotnetSdk '2.0.0-preview1-005899' 'release/2.0.0'

Using-Sdk $sdkStable

dotnet msbuild build.proj /m /v:diag /p:Architecture=$Architecture $ExtraParameters
if ($LASTEXITCODE -ne 0) { throw "Failed to build" } 
