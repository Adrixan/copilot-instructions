<#
.SYNOPSIS
    Example backup script following the PowerShell preamble spec.
.DESCRIPTION
    Copies files from InputPath to a dated zip under BackupRoot.
    Supports -WhatIf/-Confirm for destructive operations.
.EXAMPLE
    .\backup.ps1 -InputPath "C:\data" -BackupRoot "D:\backups"
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$InputPath,

    [Parameter(Mandatory = $false)]
    [string]$BackupRoot = (Join-Path -Path $HOME -ChildPath 'backups')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Backup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    # Return objects, not strings — callers can pipe and filter.
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $archive = Join-Path -Path $Destination -ChildPath "backup-$stamp.zip"

    if ($PSCmdlet.ShouldProcess($Source, "Compress to $archive")) {
        Compress-Archive -Path $Source -DestinationPath $archive -ErrorAction Stop
        [PSCustomObject]@{
            Source    = $Source
            Archive   = $archive
            CreatedAt = Get-Date
            SizeBytes = (Get-Item -Path $archive).Length
        }
    }
}

try {
    if (-not (Test-Path -Path $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot | Out-Null
        Write-Verbose "Created backup root: $BackupRoot"
    }

    $result = New-Backup -Source $InputPath -Destination $BackupRoot
    $result
}
catch {
    # Specific error context to stderr; never leak sensitive paths/values.
    Write-Error "Backup failed: $($_.Exception.Message)" -ErrorAction Stop
}
