---
applyTo: 
  - "**/*.sh"
  - "**/*.ps1"
---
<agent_profile>
Role: Automation Specialist
Skills: Bash, PowerShell, Shell Scripting
Focus: Cross-platform compatibility, Error Handling, Idempotency
Examples: See examples/scripting/ for platform-specific patterns
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **Bash:** `set -euo pipefail` at top (exit on error, undefined vars, pipe failures)
- **PowerShell:** `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`
- **Quoting:** Always quote variables: `"$VAR"` not `$VAR`
- **Portability:** Test on multiple shells/versions
- **Error Handling:** Check exit codes, provide meaningful errors
- **Idempotency:** Safe to run multiple times
- **Logging:** stderr for errors, stdout for output
- **Documentation:** Header comment with usage, requirements
</quick_reference>

<bash_standards>
**Bash/Zsh Best Practices:**

## Preamble (MANDATORY)

```bash
#!/usr/bin/env bash
# Description: Brief description of what this script does
# Usage: ./script.sh [options] <required-arg>
# Requirements: curl, jq

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Safe word splitting

# Optional: Enable debug mode with DEBUG=1
if [[ "${DEBUG:-0}" == "1" ]]; then
    set -x
fi
```

**Explanation:**
- `-e`: Exit immediately if any command fails
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Fail if any command in a pipe fails
- `IFS=$'\n\t'`: Prevent word splitting on spaces

---

## Variable Quoting

```bash
# ❌ Bad: Unquoted variables (breaks with spaces)
file=$1
cat $file
rm $file

# ✅ Good: Quoted variables
file="$1"
cat "$file"
rm "$file"

# ✅ Good: Array for command arguments
files=("file 1.txt" "file 2.txt")
for file in "${files[@]}"; do
    cat "$file"
done
```

---

## Conditional Tests

```bash
# ✅ Use [[ ]] over [ ] (more features, safer)
if [[ -f "$file" ]]; then
    echo "File exists"
fi

if [[ "$var" == "value" ]]; then
    echo "Match"
fi

# Pattern matching
if [[ "$filename" == *.txt ]]; then
    echo "Text file"
fi

# Regular expressions
if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Valid semver"
fi
```

---

## Functions

```bash
# ✅ Good: Function with error handling
function install_package() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        echo "Error: Package name required" >&2
        return 1
    fi
    
    echo "Installing $package..."
    
    if ! apt-get install -y "$package"; then
        echo "Error: Failed to install $package" >&2
        return 1
    fi
    
    echo "Successfully installed $package"
    return 0
}

# Usage
if ! install_package "nginx"; then
    echo "Installation failed, exiting" >&2
    exit 1
fi
```

---

## Error Handling

```bash
# ✅ Check command success
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed" >&2
    exit 1
fi

# ✅ Capture and check output
output=$(curl -fsSL https://api.example.com/data 2>&1)
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch data: $output" >&2
    exit 1
fi

# ✅ Cleanup on exit (trap)
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Script continues... file automatically deleted on exit
```

---

## Argument Parsing

```bash
function usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <input-file>

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -o, --output FILE   Output file (default: output.txt)

Example:
    $0 --verbose --output result.txt input.txt
EOF
}

# Parse arguments
verbose=0
output="output.txt"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            input_file="$1"
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "${input_file:-}" ]]; then
    echo "Error: Input file required" >&2
    usage
    exit 1
fi
```

---

## Idempotency

```bash
# ✅ Check before creating
if [[ ! -d "/opt/myapp" ]]; then
    mkdir -p "/opt/myapp"
fi

# ✅ Check if already running
if pgrep -f "myapp" > /dev/null; then
    echo "Application already running"
    exit 0
fi

# ✅ Safe configuration edits
if ! grep -q "^max_connections" /etc/myapp.conf; then
    echo "max_connections=100" >> /etc/myapp.conf
fi
```

---

## Logging

```bash
# Log functions
function log_info() {
    echo "[INFO] $*" >&2
}

function log_error() {
    echo "[ERROR] $*" >&2
}

function log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Usage
log_info "Starting deployment..."
log_debug "Current directory: $(pwd)"

if ! check_prerequisites; then
    log_error "Prerequisites check failed"
    exit 1
fi
```

---

## Cross-Platform Considerations

```bash
# Detect OS
case "$(uname -s)" in
    Linux*)
        os="linux"
        package_manager="apt-get"
        ;;
    Darwin*)
        os="macos"
        package_manager="brew"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        os="windows"
        package_manager="choco"
        ;;
    *)
        echo "Error: Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac

log_info "Detected OS: $os"
```

</bash_standards>

<powershell_standards>
**PowerShell Best Practices:**

## Preamble (MANDATORY)

```powershell
<#
.SYNOPSIS
    Brief description of what this script does

.DESCRIPTION
    Longer description with more details

.PARAMETER InputPath
    Path to the input file

.PARAMETER OutputPath
    Path to the output file (optional)

.EXAMPLE
    .\script.ps1 -InputPath "C:\data\input.txt" -OutputPath "C:\data\output.txt"

.NOTES
    Requires: PowerShell 7.0+
    Author: Your Name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$InputPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "output.txt"
)

# Strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # Speeds up web requests
```

---

## Naming Conventions

```powershell
# ✅ Verb-Noun naming (approved verbs only)
function Get-UserData { ... }
function Set-Configuration { ... }
function New-BackupFile { ... }
function Remove-OldLogs { ... }

# Get approved verbs
Get-Verb

# ❌ Bad: Non-standard verbs
function Fetch-Data { ... }
function Create-Thing { ... }
```

---

## Error Handling

```powershell
# ✅ Try-Catch with specific error types
try {
    $content = Get-Content -Path $InputPath -ErrorAction Stop
    $parsed = $content | ConvertFrom-Json -ErrorAction Stop
}
catch [System.IO.FileNotFoundException] {
    Write-Error "File not found: $InputPath"
    exit 1
}
catch [System.ArgumentException] {
    Write-Error "Invalid JSON format in file: $InputPath"
    exit 1
}
catch {
    Write-Error "Unexpected error: $_"
    exit 1
}

# ✅ Test before executing
if (-not (Test-Path $InputPath)) {
    Write-Error "Input file does not exist: $InputPath"
    exit 1
}
```

---

## Functions with Proper Parameters

```powershell
function Install-Application {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Stable', 'Beta', 'Dev')]
        [string]$Channel = 'Stable',
        
        [switch]$Force
    )
    
    begin {
        Write-Verbose "Starting installation process"
    }
    
    process {
        Write-Host "Installing $ApplicationName ($Channel channel)..."
        
        if ($Force) {
            Write-Warning "Force flag enabled - skipping checks"
        }
        
        # Installation logic here
    }
    
    end {
        Write-Verbose "Installation complete"
    }
}

# Usage
Install-Application -ApplicationName "MyApp" -Verbose
"App1", "App2" | Install-Application -Channel Beta
```

---

## Output Streams

```powershell
# Information (can be captured)
Write-Host "User-facing message"

# Verbose (only with -Verbose)
Write-Verbose "Detailed diagnostic message"

# Warning
Write-Warning "Something might be wrong"

# Error (non-terminating)
Write-Error "An error occurred"

# Debug (only with -Debug)
Write-Debug "Debug information"

# ✅ Return objects, not strings
function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS = (Get-CimInstance Win32_OperatingSystem).Caption
        Memory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
        Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    }
}

# Can be piped and formatted
Get-SystemInfo | Format-Table
Get-SystemInfo | ConvertTo-Json
```

---

## Working with Files

```powershell
# ✅ Use built-in cmdlets
$content = Get-Content -Path "file.txt"
$json = Get-Content -Path "data.json" | ConvertFrom-Json
$csv = Import-Csv -Path "data.csv"

Set-Content -Path "output.txt" -Value "Hello"
$data | ConvertTo-Json | Set-Content -Path "output.json"
$array | Export-Csv -Path "output.csv" -NoTypeInformation

# ✅ Test paths
if (Test-Path -Path $file -PathType Leaf) {
    # It's a file
}

if (Test-Path -Path $dir -PathType Container) {
    # It's a directory
}

# ✅ Create directories
New-Item -Path "C:\temp\myapp" -ItemType Directory -Force
```

---

## Cross-Platform Compatibility

```powershell
# Check OS
if ($IsWindows) {
    $configPath = "$env:APPDATA\myapp\config.json"
}
elseif ($IsLinux) {
    $configPath = "$env:HOME/.config/myapp/config.json"
}
elseif ($IsMacOS) {
    $configPath = "$env:HOME/Library/Application Support/myapp/config.json"
}

# Use Join-Path for cross-platform paths
$logPath = Join-Path -Path $configDir -ChildPath "logs"
```

---

## Performance Optimization

```powershell
# ✅ Pipeline instead of loops (faster)
1..10000 | ForEach-Object { $_ * 2 }

# ❌ Avoid string concatenation in loops
$result = ""
foreach ($item in $items) {
    $result += $item  # Creates new string each time!
}

# ✅ Use StringBuilder for string building
$sb = [System.Text.StringBuilder]::new()
foreach ($item in $items) {
    [void]$sb.Append($item)
}
$result = $sb.ToString()

# ✅ Use ArrayList for growing collections
$list = [System.Collections.ArrayList]::new()
foreach ($item in $items) {
    [void]$list.Add($item)
}
```

</powershell_standards>

<common_pitfalls>
**Frequent Scripting Mistakes:**

## Bash Pitfalls

1. **Unquoted Variables:**
   ```bash
   # ❌ Breaks with spaces/special chars
   file=$1
   cat $file
   
   # ✅ Always quote
   file="$1"
   cat "$file"
   ```

2. **Not Checking Command Success:**
   ```bash
   # ❌ Continues even if fails
   cd /important/directory
   rm -rf *
   
   # ✅ Check first
   cd /important/directory || exit 1
   rm -rf *
   ```

3. **Word Splitting Issues:**
   ```bash
   # ❌ Bad: Splits on whitespace
   files=$(ls *.txt)
   for file in $files; do
       echo "$file"
   done
   
   # ✅ Good: Proper array handling
   files=(*.txt)
   for file in "${files[@]}"; do
       echo "$file"
   done
   ```

---

## PowerShell Pitfalls

1. **Not Using -ErrorAction:**
   ```powershell
   # ❌ Continues on non-terminating errors
   Get-Content "nonexistent.txt"
   
   # ✅ Make it stop
   Get-Content "nonexistent.txt" -ErrorAction Stop
   ```

2. **Incorrect Comparison Operators:**
   ```powershell
   # ❌ Wrong: Uses -eq for strings
   if ($var == "value") { }
   
   # ✅ Correct: PowerShell operators
   if ($var -eq "value") { }
   if ($number -gt 10) { }
   if ($string -like "*pattern*") { }
   ```

3. **Not Honoring WhatIf/Confirm:**
   ```powershell
   # ✅ Support common parameters
   function Remove-OldFiles {
       [CmdletBinding(SupportsShouldProcess=$true)]
       param([string]$Path)
       
       if ($PSCmdlet.ShouldProcess($Path, "Delete old files")) {
           Remove-Item -Path $Path\*.log -Force
       }
   }
   
   # Users can now safely test
   Remove-OldFiles -Path "C:\logs" -WhatIf
   ```

**Examples:** See examples/scripting/pitfalls.md for detailed code examples.

</common_pitfalls>

<testing_validation>
**Script Testing:**

## Bash Testing (with BATS)

```bash
# test.bats
#!/usr/bin/env bats

@test "function returns success for valid input" {
    run my_function "valid-arg"
    [ "$status" -eq 0 ]
    [ "$output" = "Expected output" ]
}

@test "function fails for invalid input" {
    run my_function ""
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error:" ]]
}
```

**Run tests:**
```bash
bats test.bats
```

**Comprehensive Example:** See [examples/scripting/test_deploy.bats](../examples/scripting/test_deploy.bats) for complete BATS test suite with 25+ tests covering argument parsing, validation, prerequisites, dry-run mode, and error handling

---

## PowerShell Testing (with Pester)

```powershell
# MyScript.Tests.ps1
Describe "Get-UserData" {
    It "Returns user data for valid ID" {
        $result = Get-UserData -UserId 123
        $result | Should -Not -BeNullOrEmpty
        $result.Id | Should -Be 123
    }
    
    It "Throws error for invalid ID" {
        { Get-UserData -UserId -1 } | Should -Throw
    }
}
```

**Run tests:**
```powershell
Invoke-Pester -Path .\MyScript.Tests.ps1
```

**Comprehensive Example:** See [examples/scripting/backup.Tests.ps1](../examples/scripting/backup.Tests.ps1) for complete Pester test suite with 30+ tests including parameter validation, unit tests, integration tests with TestDrive, and transaction rollback tests

---

## ShellCheck (Static Analysis)

```bash
# Install
apt-get install shellcheck  # Debian/Ubuntu
brew install shellcheck     # macOS

# Run
shellcheck script.sh

# Inline disable (use sparingly)
# shellcheck disable=SC2086
echo $var
```

---

## Validation Checklist

- [ ] Script has `set -euo pipefail` (Bash) or `Set-StrictMode` (PS)
- [ ] All variables are quoted
- [ ] Exit codes are checked
- [ ] Help/usage function exists
- [ ] Script is idempotent
- [ ] Error messages go to stderr
- [ ] Tested on target platform(s)
- [ ] ShellCheck/PSScriptAnalyzer passes
- [ ] Functions have [CmdletBinding()] (PowerShell)

</testing_validation>

<best_practices_summary>
**Quick Checklist:**

### Bash
- [ ] `#!/usr/bin/env bash` shebang
- [ ] `set -euo pipefail` at top
- [ ] Variables quoted: `"$var"`
- [ ] Use `[[ ]]` for conditions
- [ ] Functions for reusable logic
- [ ] `trap` for cleanup
- [ ] Usage documentation

### PowerShell
- [ ] `[CmdletBinding()]` for advanced functions
- [ ] `Set-StrictMode -Version Latest`
- [ ] Verb-Noun naming
- [ ] Parameter validation
- [ ] Try-Catch error handling
- [ ] Write-Verbose for diagnostics
- [ ] Comment-based help

### Both
- [ ] Meaningful error messages
- [ ] Exit codes (0 = success, non-zero = failure)
- [ ] Idempotency (safe to run multiple times)
- [ ] Cross-platform if needed
- [ ] Tested on target systems
- [ ] Version control friendly (no secrets)

</best_practices_summary>

