````instructions
---
applyTo: 
  - "**/*.sh"
  - "**/*.ps1"
---
<agent_profile>
Role: Automation Specialist
Skills: Bash, PowerShell, Shell Scripting
Focus: Cross-platform compatibility, Error Handling, Idempotency
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **Bash:** `set -euo pipefail` at top of every script
- **PowerShell:** `Set-StrictMode -Version Latest` + `$ErrorActionPreference = 'Stop'`
- **Quoting:** Always quote variables: `"$VAR"` not `$VAR`
- **Error Handling:** Check exit codes, provide meaningful errors to stderr
- **Idempotency:** Safe to run multiple times without side effects
- **Logging:** stderr for errors/diagnostics, stdout for output
- **Documentation:** Header comment with description, usage, and requirements
</quick_reference>

<bash_standards>

## Preamble (MANDATORY)

```bash
#!/usr/bin/env bash
# Description: Brief description
# Usage: ./script.sh [options] <required-arg>
# Requirements: curl, jq

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-0}" == "1" ]] && set -x
```

## Key Rules

- **Use `[[ ]]`** over `[ ]` for conditionals (pattern matching, safer)
- **Quote all variables:** `"$var"`, `"${files[@]}"`
- **Use arrays** for file lists: `files=(*.txt); for f in "${files[@]}"` — never parse `ls` output
- **Trap for cleanup:** `trap 'rm -f "$tmpfile"' EXIT`
- **Check commands:** `command -v docker &>/dev/null || { echo "Error: docker required" >&2; exit 1; }`
- **Idempotent operations:** Check before creating (`[[ ! -d "$dir" ]] && mkdir -p "$dir"`)
- **Functions:** Use `local` for variables, return meaningful exit codes, send errors to stderr

## Argument Parsing

Use `while [[ $# -gt 0 ]]; case ... esac` pattern with `--help`, shift properly, validate required args after loop.

See [examples/scripting/deploy.sh](../examples/scripting/deploy.sh) for a complete production deployment script.
See [examples/scripting/test_deploy.bats](../examples/scripting/test_deploy.bats) for BATS test patterns.

</bash_standards>

<powershell_standards>

## Preamble (MANDATORY)

```powershell
<#
.SYNOPSIS
    Brief description
.PARAMETER InputPath
    Description of parameter
.EXAMPLE
    .\script.ps1 -InputPath "C:\data\input.txt"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$InputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

## Key Rules

- **Verb-Noun naming:** `Get-UserData`, `Set-Configuration`, `New-BackupFile` (approved verbs only)
- **`[CmdletBinding()]`** on all functions for `-Verbose`, `-WhatIf` support
- **Parameter validation:** `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`, `[ValidateScript()]`
- **Try-Catch** with specific exception types, `-ErrorAction Stop` on cmdlets
- **Return objects** (PSCustomObject), not strings — enables piping and formatting
- **Test-Path** before file operations
- **SupportsShouldProcess** for destructive operations (`-WhatIf` / `-Confirm`)
- **Cross-platform:** Use `$IsWindows`/`$IsLinux`/`$IsMacOS` and `Join-Path` for paths

See [examples/scripting/backup.ps1](../examples/scripting/backup.ps1) for a complete PowerShell script.
See [examples/scripting/backup.Tests.ps1](../examples/scripting/backup.Tests.ps1) for Pester test patterns.

</powershell_standards>

<common_pitfalls>

## Bash
1. **Unquoted variables** → word splitting, glob expansion. Always `"$var"`.
2. **Not checking command success** → `cd /dir && rm -rf *` or `cd /dir || exit 1` — never bare `cd`.
3. **Parsing ls output** → use globs: `for f in *.txt` or `find ... -exec`.

## PowerShell
1. **Missing `-ErrorAction Stop`** → non-terminating errors silently continue.
2. **`==` instead of `-eq`** → PowerShell uses `-eq`, `-gt`, `-like`, `-match` operators.
3. **No `SupportsShouldProcess`** → destructive functions can't be safely tested with `-WhatIf`.

</common_pitfalls>

<security_standards>
**Governing Standards:** CWE/SANS Top 25 (relevant entries), CIS Benchmarks (OS hardening scripts).

**Key Risks for Scripts:**
- **CWE-78 OS Command Injection:** Never pass unsanitized input to `eval`, `bash -c`, `Invoke-Expression`, or backtick execution. Use arrays for command construction, not string interpolation.
- **CWE-22 Path Traversal:** Validate and canonicalize all file paths. Reject `..` sequences. Use `realpath` (Bash) or `Resolve-Path` (PowerShell) before operations.
- **CWE-377 Insecure Temp Files:** Use `mktemp` (Bash) or `[System.IO.Path]::GetTempFileName()` (PowerShell). Never use predictable temp file names. Clean up via trap/finally.
- **CWE-269 Privilege Escalation:** Scripts requiring elevated privileges must: document why, use `sudo` only for specific commands (not the entire script), and drop privileges as soon as possible.
- **CWE-312 Cleartext Storage of Sensitive Info:** Never store passwords, tokens, or keys in script variables that get logged. Use `read -rs` (Bash) or `Get-Credential` (PowerShell) for interactive secrets. Mask sensitive output.

**Implementation Checklist:**
1. **Input Sanitization:** Validate all arguments. Reject unexpected characters. Allowlist, don't blocklist.
2. **No Eval/Invoke-Expression:** Avoid dynamic code execution. If unavoidable, validate input against a strict allowlist.
3. **File Permissions:** Set restrictive permissions on created files (`umask 077` / `icacls`). Never create world-readable files containing credentials.
4. **Secure Defaults:** Scripts should fail-safe (strict mode). Default to non-destructive operations. Require explicit `--force` for dangerous actions.
5. **Credential Handling:** Accept secrets via environment variables or stdin, never as command-line arguments (visible in `ps` output). Use `SecureString` in PowerShell.
6. **Logging:** Never log sensitive values. Redact credentials in error messages. Log to stderr, not stdout (stdout may be piped elsewhere).
</security_standards>

<testing_validation>

## Testing
- **Bash:** [BATS](https://github.com/bats-core/bats-core) — `run my_function "arg"; [ "$status" -eq 0 ]`
- **PowerShell:** [Pester](https://pester.dev/) — `Describe/It/Should` pattern
- **Static Analysis:** ShellCheck for Bash, PSScriptAnalyzer for PowerShell

## Validation Checklist
- [ ] Strict mode enabled (`set -euo pipefail` / `Set-StrictMode`)
- [ ] Variables quoted / parameters validated
- [ ] Exit codes checked / errors handled
- [ ] Help/usage function exists
- [ ] Script is idempotent
- [ ] Errors go to stderr
- [ ] Static analysis passes (ShellCheck / PSScriptAnalyzer)

</testing_validation>
````
