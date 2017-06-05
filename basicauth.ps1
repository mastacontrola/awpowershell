<# Source file for basic auth generation function.
    .SYNOPSIS
        Gives a common source for the basic auth function.

    .USAGE
        Only used to source a function, there is no true usage.
#>
Function Get-BasicUserForAuth {
    Param(
        [string]$func_username
    )

    $encoding = [System.Text.Encoding]::ASCII.GetBytes($func_username);
    $encodedString = [Convert]::ToBase64String($encoding);
    
    $fullencoded = "Basic " + $encodedString;

    Write-Verbose("");
    Write-Verbose("---------- Basic Auth ----------");
    Write-Verbose("Encoded String: " + $fullencoded);
    Write-Verbose("--------------------------------");
    Write-Verbose("");

    Return "Basic " + $encodedString;
}
