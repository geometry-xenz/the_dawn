# ==============================================================================
# Script: Daily Learning Logger
# Description: Captures daily learnings, saves them to a structured JSON database,
#              generates a Markdown summary, and updates a master user list.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. USER INPUT & DATE SETUP
# ------------------------------------------------------------------------------
$name = Read-Host "What is your name"
$entry = Read-Host "What did you learn today ?"

# Grab the current date and format it for our folders and Markdown
$day = Get-Date -Format 'dd'
$month = Get-Date -Format 'MMMM'
$year = Get-Date -Format 'yyyy'

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
$all_learning = $user.Learning -join "`n`t- "

# Build the Markdown template using subexpressions $() for string manipulation
$readme = "# $($name.ToUpper()) Learning

### $day, $month $year

## What did I learn today ?

`t- $all_learning
"

# Create or overwrite the Markdown file with the complete history for the day
$md_filename = "$($name.ToLower())_learning.md"
New-Item -Path "./$month/$day" -Name $md_filename -Value $readme -Force | Out-Null

Write-Output ">> Markdown file updated!"

# ------------------------------------------------------------------------------
# 5. MASTER USER DATABASE (userdb.json)
# ------------------------------------------------------------------------------
$userdb_path = "./userdb.json"
$check_db = Test-Path $userdb_path

# Create a blank JSON array if the master database doesn't exist
if (-not $check_db) {
    New-Item -Path "./" -Name 'userdb.json' -Value "[]" | Out-Null
}

# Read the JSON string
$db_data = Get-Content $userdb_path -Raw

# Convert to a PowerShell Array
[array]$db = ConvertFrom-Json $db_data

# If the user is not in the master list, add them
if ($db -notcontains $name.ToLower()) {
    $db += $name.ToLower()
}

# Convert back to JSON (forcing it as an array to prevent string gluing)
$db_updated = ConvertTo-Json @($db)
Set-Content $userdb_path -Value $db_updated

Write-Output ">> Master User database updated successfully!"
Write-Output "Done."