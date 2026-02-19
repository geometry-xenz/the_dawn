$name = Read-Host "What is your name"


$entry = Read-Host "What did you learn today ?"

$day = Get-Date -Format 'dd'
$month = Get-Date -Format 'MMMM'
$year = Get-Date -Format 'yyyy'


Write-Output $day $month

if (-not(Test-Path ./$month)){

    New-Item -Path "./" -Name $month -ItemType Directory
}
if (-not(Test-Path ./$month/$day)){
    New-Item -Path "./$month" -Name $day -ItemType Directory

}




# ENTRIES DATABASE FOR EACH DAY

# Check if entry db is present
$check_entries_db = Test-Path "./$month/$day/entries.json"


if (!$check_entries_db) {
    New-Item -Path ./$month/$day/ -Name 'entries.json' -Value "[]"
}

$entries = Get-Content "./$month/$day/entries.json" -Raw

[array]$edb = ConvertFrom-Json $entries

$user = $edb | Where-Object { $_.User -eq $name }


if (-not $user) {
    $new_record = [PSCustomObject]@{
        User     = $name.ToLower()
        Learning = @($entry)
    }
    $edb += $new_record
}
else {
    $user.Learning += $entry
}

$edb_json = ConvertTo-Json $edb

Set-Content "./$month/$day/entries.json" -Value $edb_json


Write-Output "Entries record saved to Json"

$user = $edb | Where-Object { $_.User -eq $name }

$all_learning = $user.Learning -join "`n`t- "

$readme = "# $($name.ToUpper()) Learning

### $day, $month $year

## What did I learn today ?

`t- $all_learning
"

New-Item -Path "./$month/$day" -Name "$($name.ToLower())_learning.md" -Value $readme -Force


# USER DATABASE CHECK

$check_db = Test-Path ./userdb.json

if (!$check_db){
    New-Item -Path ./ -Name 'userdb.json' -Value "[]"
}

Write-Output "User database created succesfully !!"

$db_data = Get-Content "./userdb.json" -Raw

$db = ConvertFrom-Json $db_data


if ($db -notcontains $name){
    $db += $name.ToLower()
}

$db_updated = ConvertTo-Json @($db)

Set-Content "./userdb.json" -Value $db_updated

Write-Output "Updated the Entries in User database !!"
