$TestsPath = Split-Path $MyInvocation.MyCommand.Path

#$FunctionsPath = join-Path -Path (get-item $TestsPath).Parent -ChildPath "Functions"

$RootFolder = (get-item $TestsPath).Parent

Push-Location -Path $RootFolder.FullName

set-location -Path $RootFolder.FullName

Write-Verbose "Importing module"

import-module .\PSHTML -Force

InModuleScope -ModuleName PSHTML {

    Describe '[LogFile]-[Constructors]' {
    
        It '[LogFile]-[Constructor] - Parameterless - should Not Throw' {
            Get-PSCallStack

            { [LogFile]::New() } | Should not throw
    
        } #End of it block
    
    }

}
