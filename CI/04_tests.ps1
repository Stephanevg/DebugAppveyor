
$PSVersionTable
Write-Host "[TEST][START]" -ForegroundColor RED -BackgroundColor White
import-module pester
start-sleep -seconds 2

write-output "BUILD_FOLDER: $($env:APPVEYOR_BUILD_FOLDER)"
write-output "PROJECT_NAME: $($env:APPVEYOR_PROJECT_NAME)"
write-output "BRANCH: $($env:APPVEYOR_REPO_BRANCH)"
$ModuleClonePath = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath $env:APPVEYOR_PROJECT_NAME
Write-Output "MODULE CLONE PATH: $($ModuleClonePath)"

$ModuleClonePath = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath $env:APPVEYOR_PROJECT_NAME

$moduleName = "$($env:APPVEYOR_PROJECT_NAME)"
Get-Module $moduleName

#Pester Tests
write-verbose "invoking pester"
#$TestFiles = (Get-ChildItem -Path .\ -Recurse  | ?{$_.name.EndsWith(".ps1") -and $_.name -notmatch ".tests." -and $_.name -notmatch "build" -and $_.name -notmatch "Example"}).Fullname


$res = Invoke-Pester -Path "$($env:APPVEYOR_BUILD_FOLDER)/Tests" -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru #-CodeCoverage $TestFiles

#Uploading Testresults to Appveyor
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path ./TestsResults.xml))


if ($res.FailedCount -gt 0 -or $res.PassedCount -eq 0) { 
    $PSVersionTable
    $AllFailedTests = $res.TestResult | ? {$_.Passed -eq $false}
    foreach ($failedTest in $AllFailedTests){

        "Describe: {0}" -f $failedTest.describe
        "Name: {0}" -f $failedTest.Name
        "Message: {0}" -f $failedTest.FailureMessage
    }
    throw "$($res.FailedCount) tests failed - $($res.PassedCount) successfully passed"
};
