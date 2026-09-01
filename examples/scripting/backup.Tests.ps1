# Pester tests for backup.ps1 — run: Invoke-Pester ./backup.Tests.ps1

BeforeAll {
    . (Join-Path $PSScriptRoot 'backup.ps1') -WhatIf -ErrorAction SilentlyContinue 2>$null
    # Dot-source only the function under test if the script executes top-level:
}

Describe 'New-Backup' {
    BeforeAll {
        $TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) "backup-tests-$([guid]::NewGuid())"
        $Source = Join-Path $TestRoot 'data'
        $Destination = Join-Path $TestRoot 'out'
        New-Item -ItemType Directory -Path $Source, $Destination -Force | Out-Null
        Set-Content -Path (Join-Path $Source 'file.txt') -Value 'payload'
    }

    AfterAll {
        Remove-Item -Path $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'creates a zip archive and returns a result object' {
        $result = New-Backup -Source $Source -Destination $Destination

        $result | Should -Not -BeNullOrEmpty
        $result.Archive | Should -Exist
        $result.SizeBytes | Should -BeGreaterThan 0
    }

    It 'supports WhatIf without creating the archive' {
        $before = (Get-ChildItem -Path $Destination -Filter '*.zip').Count
        New-Backup -Source $Source -Destination $Destination -WhatIf

        (Get-ChildItem -Path $Destination -Filter '*.zip').Count | Should -Be $before
    }

    It 'throws on missing source' {
        { New-Backup -Source (Join-Path $TestRoot 'missing') -Destination $Destination } |
            Should -Throw
    }
}
