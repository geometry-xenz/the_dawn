# ==============================================================================
# Script: Daily Learning Logger
# Description: Captures daily learnings, saves them to a structured JSON database,
#              generates a Markdown summary, and updates a master user list.
# ==============================================================================

# ------------------------------------------------------------------------------
# ANSI COLOR HELPERS
# ------------------------------------------------------------------------------
$ESC = [char]27
$RESET = "$ESC[0m"
$BOLD = "$ESC[1m"
$DIM = "$ESC[2m"

# Foreground colors
$FG_BLACK = "$ESC[30m"
$FG_RED = "$ESC[31m"
$FG_GREEN = "$ESC[32m"
$FG_YELLOW = "$ESC[33m"
$FG_BLUE = "$ESC[34m"
$FG_MAGENTA = "$ESC[35m"
$FG_CYAN = "$ESC[36m"
$FG_WHITE = "$ESC[37m"

# Background colors
$BG_BLUE = "$ESC[44m"
$BG_CYAN = "$ESC[46m"
$BG_BLACK = "$ESC[40m"

# Compound styles
$HEADER = "$BOLD$FG_CYAN"
$ACCENT = "$BOLD$FG_YELLOW"
$SUCCESS = "$BOLD$FG_GREEN"
$ERROR_CLR = "$BOLD$FG_RED"
$INFO = "$FG_BLUE"
$MUTED = "$DIM$FG_WHITE"
$PROMPT_CLR = "$BOLD$FG_MAGENTA"

# ------------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------
function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE                                          $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ██████╗  █████╗ ██╗    ██╗███╗   ██╗  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ██╔══██╗██╔══██╗██║    ██║████╗  ██║  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ██║  ██║███████║██║ █╗ ██║██╔██╗ ██║  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ██║  ██║██╔══██║██║███╗██║██║╚██╗██║  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ██████╔╝██║  ██║╚███╔███╔╝██║ ╚████║  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE    ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝  $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE         Daily Learning Logger              $RESET"
    Write-Host "  $BOLD$BG_BLUE$FG_WHITE                                            $RESET"
    Write-Host ""
}

function Write-SectionHeader([string]$Title) {
    Write-Host ""
    Write-Host "  $HEADER┌─────────────────────────────────────┐$RESET"
    Write-Host "  $HEADER│  $ACCENT$Title$HEADER$((' ' * (36 - $Title.Length)))│$RESET"
    Write-Host "  $HEADER└─────────────────────────────────────┘$RESET"
    Write-Host ""
}

function Write-Success([string]$msg) {
    Write-Host "  $SUCCESS✔  $msg$RESET"
}

function Write-Err([string]$msg) {
    Write-Host "  $ERROR_CLR✘  $msg$RESET"
}

function Write-Info([string]$msg) {
    Write-Host "  $INFO➜  $msg$RESET"
}

function Write-Divider {
    Write-Host "  $MUTED$('─' * 42)$RESET"
}

# ------------------------------------------------------------------------------
# 1. DATE SETUP & USER DATABASE
# ------------------------------------------------------------------------------
$userdb_path = "./userdb.json"

$day = Get-Date -Format 'dd'
$month = Get-Date -Format 'MMMM'
$year = Get-Date -Format 'yyyy'

if (-not (Test-Path $userdb_path)) {
    New-Item -Path "./" -Name 'userdb.json' -Value "[]" | Out-Null
}

[array]$db = ConvertFrom-Json (Get-Content $userdb_path -Raw)

# ------------------------------------------------------------------------------
# 2. USER SELECTION
# ------------------------------------------------------------------------------
$isValid = $false
do {
    Write-Banner
    Write-SectionHeader "Select User"

    for ($i = 0; $i -lt $db.Count; $i++) {
        Write-Host "    $ACCENT$($i + 1))$RESET  $FG_WHITE$($db[$i])$RESET"
    }

    Write-Host ""
    [int]$user_no = Read-Host "  $PROMPT_CLR  Who are you?$RESET "

    if ((0 -lt $user_no) -and ($user_no -le $db.Count)) {
        $isValid = $true
        [string]$name = $db[$user_no - 1]
    }
    else {
        Write-Err "Invalid selection. Try again."
        Start-Sleep -Seconds 1
    }
} until ($isValid)

Write-Info "Logged in as $ACCENT$($name.ToUpper())$RESET"
Start-Sleep -Milliseconds 600

# ------------------------------------------------------------------------------
# 3. MAIN APPLICATION LOOP — keeps running until user chooses to Exit
# ------------------------------------------------------------------------------
$running = $true

while ($running) {

    # ── Menu ──────────────────────────────────────────────────────────────────
    $isValid = $false
    do {
        Write-Banner
        Write-Host "  $MUTED$(Get-Date -Format 'dddd, dd MMMM yyyy  •  HH:mm')$RESET"
        Write-Host ""
        Write-Host "  $BOLD$FG_WHITE Hello, $ACCENT$($name.ToUpper())$RESET"
        Write-SectionHeader "What would you like to do?"

        Write-Host "    $ACCENT1)$RESET  $FG_WHITE Log an Entry$RESET"
        Write-Host "    $ACCENT2)$RESET  $FG_WHITE Retrieve an Entry$RESET"
        Write-Host "    $ACCENT3)$RESET  $FG_WHITE Exit$RESET"
        Write-Host ""

        [int]$choice = Read-Host "  $PROMPT_CLR  Choose 1–3$RESET "

        if ($choice -notin 1..3) {
            Write-Err "Invalid choice. Please enter 1, 2, or 3."
            Start-Sleep -Seconds 1
        }
        else {
            $isValid = $true
        }
    } until ($isValid)

    # ── Option 3: Exit ────────────────────────────────────────────────────────
    if ($choice -eq 3) {
        Write-Banner
        Write-Host "  $SUCCESS Goodbye, $($name.ToUpper())! Keep learning every day.$RESET"
        Write-Host ""
        $running = $false
        break
    }

    # ── Option 1: Log Entry ───────────────────────────────────────────────────
    if ($choice -eq 1) {

        $logging = $true

        while ($logging) {
            Write-Banner
            Write-SectionHeader "Log a Learning Entry"
            Write-Host "  $MUTED Date: $day $month $year$RESET"
            Write-Host "  $MUTED User: $($name.ToUpper())$RESET"
            Write-Divider
            Write-Host ""

            $entry = Read-Host "  $PROMPT_CLR  What did you learn today?$RESET "

            if ([string]::IsNullOrWhiteSpace($entry)) {
                Write-Err "Entry cannot be empty."
                Start-Sleep -Seconds 1
                continue
            }

            # ── Directory structure ──────────────────────────────────────────
            if (-not (Test-Path "./$month")) { New-Item -Path "./"      -Name $month -ItemType Directory | Out-Null }
            if (-not (Test-Path "./$month/$day")) { New-Item -Path "./$month" -Name $day  -ItemType Directory | Out-Null }

            # ── entries.json ─────────────────────────────────────────────────
            $entries_db_path = "./$month/$day/entries.json"
            if (-not (Test-Path $entries_db_path)) {
                New-Item -Path "./$month/$day/" -Name 'entries.json' -Value "[]" | Out-Null
            }

            [array]$edb = ConvertFrom-Json (Get-Content $entries_db_path -Raw)
            $user_record = $edb | Where-Object { $_.User -eq $name }

            if (-not $user_record) {
                $new_record = [PSCustomObject]@{
                    User     = $name.ToLower()
                    Learning = @($entry)
                }
                $edb += $new_record
            }
            else {
                $user_record.Learning += $entry
            }

            Set-Content $entries_db_path -Value (ConvertTo-Json @($edb))
            Write-Success "Entry saved to daily JSON!"

            # ── Markdown ─────────────────────────────────────────────────────
            $user_record = $edb | Where-Object { $_.User -eq $name }
            $all_learning = $user_record.Learning -join "`n- "

            $readme = "# $($name.ToUpper()) Learning

### $day, $month $year

## What did I learn today?

- $all_learning
"
            $md_filename = "$($name.ToLower())_learning.md"
            New-Item -Path "./$month/$day" -Name $md_filename -Value $readme -Force | Out-Null
            Write-Success "Markdown file updated → $FG_CYAN./$month/$day/$md_filename$RESET"

            # ── Ask to log another ───────────────────────────────────────────
            Write-Host ""
            Write-Divider
            $again = Read-Host "  $PROMPT_CLR  Log another entry? (y/n)$RESET "
            if ($again -notmatch '^[Yy]') {
                $logging = $false
            }
        }
    }

    # ── Option 2: Retrieve Entry ──────────────────────────────────────────────
    elseif ($choice -eq 2) {
        Write-Banner
        Write-SectionHeader "Retrieve an Entry"

        $input_date = Read-Host "  $PROMPT_CLR  Enter date (e.g., 3 4 for 3rd April)$RESET "

        try {
            $search_date = [datetime]::ParseExact($input_date.Trim(), "d M", $null)
            $search_month = $search_date.ToString('MMMM')
            $search_day = $search_date.ToString('dd')
        }
        catch {
            Write-Err "Invalid date format. Use: day month  e.g. 3 4"
            Start-Sleep -Seconds 2
            continue
        }

        $file_path = "./$search_month/$search_day/$($name.ToLower())_learning.md"

        if (-not (Test-Path $file_path)) {
            Write-Host ""
            Write-Err "No entries found for $ACCENT$search_day $search_month$RESET under user $ACCENT$($name.ToUpper())$RESET."
        }
        else {
            Write-Banner
            Write-Host "  $HEADER╔══════════════════════════════════════════╗$RESET"
            Write-Host "  $HEADER║  $ACCENT$($name.ToUpper())'s Log — $search_day $search_month $year$HEADER$((' ' * (42 - $name.Length - 16)))║$RESET"
            Write-Host "  $HEADER╚══════════════════════════════════════════╝$RESET"
            Write-Host ""

            if (Get-Command Show-Markdown -ErrorAction SilentlyContinue) {
                Show-Markdown -Path $file_path
            }
            else {
                $lines = Get-Content $file_path
                foreach ($line in $lines) {
                    if ($line -match '^#') { Write-Host "  $ACCENT$line$RESET" }
                    elseif ($line -match '^-') { Write-Host "  $FG_GREEN$line$RESET" }
                    else { Write-Host "  $FG_WHITE$line$RESET" }
                }
            }
        }

        Write-Host ""
        Write-Divider
        Read-Host "  $MUTED  Press Enter to return to the menu$RESET "
    }

} # end while ($running)