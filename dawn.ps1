# ==============================================================================
# Script: Daily Learning Logger
# Description: Captures daily learnings, saves them to a structured JSON database,
#              generates a Markdown summary, and updates a master user list.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. USER INPUT & DATE SETUP
# ------------------------------------------------------------------------------
$userdb_path = "./userdb.json"
$check_db = Test-Path $userdb_path

# Grab the current date and format it for our folders and Markdown
$day = Get-Date -Format 'dd'
$month = Get-Date -Format 'MMMM'
$year = Get-Date -Format 'yyyy'

# Create a blank JSON array if the master database doesn't exist
if (-not $check_db) {
    New-Item -Path "./" -Name 'userdb.json' -Value "[]" | Out-Null
}

# Read the JSON string
$db_data = Get-Content $userdb_path -Raw

# Convert to a PowerShell Array
[array]$db = ConvertFrom-Json $db_data

$isValid = $false

do {
    Clear-Host

    Write-Output "`n--- Select User ---"

    for ($i = 0; $i -lt $db.Count; $i++) {
        Write-Output "$($i + 1)) $($db[$i])"
    }

    [int]$user_no = Read-Host "`n`tWho are you "

    if ((0 -lt $user_no) -and ($user_no -le $db.Count)) {
        $isValid = $true
        [string]$name = $db[$user_no - 1]
    }

} until ($isValid -eq $true)

Write-Output "`n>> Setting name = $name"

$isValid = $false

do {
    Clear-Host

    Write-Output "`nHello, $($name.ToUpper())`n`n--- What you want to do ? ---"
    Write-Output "`n`t1) Log an Entry"
    Write-Output "`n`t2) Retrive an Entry"

    [int]$choice = Read-Host "`nChoose from option 1-2 "

    if (-not (($choice -eq 1) -or ($choice -eq 2))) {
        Write-Output "`nInvalid choice. Please type 1 or 2."
        Start-Sleep -Seconds 2
    }
    else {
        $isValid = $true
    }

} until ($isValid -eq $true)


if ($choice -eq 1) {



    $entry = Read-Host "`nWhat did you learn today "



    Write-Output "Logging entry for $day $month..."

    # ------------------------------------------------------------------------------
    # 2. DIRECTORY STRUCTURE SETUP
    # ------------------------------------------------------------------------------
    # Check if the Month folder exists; if not, create it
    if (-not(Test-Path "./$month")) {
        New-Item -Path "./" -Name $month -ItemType Directory | Out-Null
    }

    # Check if the Day folder exists inside the Month folder; if not, create it
    if (-not(Test-Path "./$month/$day")) {
        New-Item -Path "./$month" -Name $day -ItemType Directory | Out-Null
    }

    # ------------------------------------------------------------------------------
    # 3. DAILY ENTRIES DATABASE (entries.json)
    # ------------------------------------------------------------------------------
    $entries_db_path = "./$month/$day/entries.json"
    $check_entries_db = Test-Path $entries_db_path

    # Create a blank JSON array if the file doesn't exist yet for today
    if (-not $check_entries_db) {
        New-Item -Path "./$month/$day/" -Name 'entries.json' -Value "[]" | Out-Null
    }

    # Read the JSON file (-Raw ensures it reads as a single string)
    $entries = Get-Content $entries_db_path -Raw

    # Convert JSON string into a PowerShell Array of objects
    [array]$edb = ConvertFrom-Json $entries

    # Search the array for the current user (Note: -eq is case-insensitive in PowerShell)
    $user = $edb | Where-Object { $_.User -eq $name }

    if (-not $user) {
        # NOT FOUND: Create a brand new record for this user
        $new_record = [PSCustomObject]@{
            User     = $name.ToLower()
            Learning = @($entry) # @() forces this to be an array from the start
        }
        # Add the new record to the daily database
        $edb += $new_record
    }
    else {
        # FOUND: Append the new learning entry to their existing list
        $user.Learning += $entry
    }

    # Convert the updated database back to JSON and save it
    $edb_json = ConvertTo-Json @($edb)
    Set-Content $entries_db_path -Value $edb_json

    Write-Output ">> Entries record saved to daily JSON!"

    # ------------------------------------------------------------------------------
    # 4. MARKDOWN GENERATION
    # ------------------------------------------------------------------------------
    # Re-fetch the user object to ensure we have the fully updated 'Learning' list
    $user = $edb | Where-Object { $_.User -eq $name }

    # Format the list of learnings into a string with newlines (`n) and tabs (`t)
    $all_learning = $user.Learning -join "`n- "

    # Build the Markdown template using subexpressions $() for string manipulation
    $readme = "# $($name.ToUpper()) Learning

### $day, $month $year

## What did I learn today ?

- $all_learning
"

    # Create or overwrite the Markdown file with the complete history for the day
    $md_filename = "$($name.ToLower())_learning.md"
    New-Item -Path "./$month/$day" -Name $md_filename -Value $readme -Force | Out-Null

    Write-Output ">> Markdown file updated!"

}
else{
    
    $input_date = Read-Host "Enter the date (e.g., 3 4 or 02 04)"
    $search_date = [datetime]::ParseExact($input_date, "d M", $null)
    $month = $search_date.ToString('MMMM') # E.g., "February"
    $day = $search_date.ToString('dd')     # E.g., "20"

    $file_path = "./$month/$day/$($name.ToLower())_learning.md"

    if (-not (Test-Path $file_path)){
        Write-Output "`n`n`t !! NO ENTRIES FOUND !!"
        Write-Output "`nExiting in 5sec ..."
        Start-Sleep -Seconds 5
    } else {
        
        Clear-Host

        # Check if the Show-Markdown command is available
        if (Get-Command Show-Markdown -ErrorAction SilentlyContinue) {
            Show-Markdown -Path $file_path
        } 
        else {
            # Fallback: Just print the raw text to the console
            Get-Content $file_path
        }
    }

}
