$name = Read-Host "What is your name"


$entry = Read-Host "What did you learn today ?"

$day = Get-Date -Format 'dd'
$month = Get-Date -Format 'MMMM'
$year = Get-Date -Format 'yyyy'

$readme = "# Krishna Learning
---
### $day, $month $year

## What did I learn today ?
---

$entry
"
Write-Output $day $month

if (!{Test-Path ./$month}){

    New-Item -Path "./" -Name $month -ItemType Directory
}
if (!{Test-Path ./$month/$day}){
    New-Item -Path "./$month" -Name $day -ItemType Directory

}

New-Item -Path "./$month/$day" -Name "${name}_learning.md" -Value $readme -Force

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
